import errno
import logging
import os
import sys
import subprocess
import json
from typing import final
from fuse import FUSE, FuseOSError, Operations, LoggingMixIn  # pyright: ignore[reportMissingTypeStubs]

STYLIX_PATH = "/etc/stylix/palette.json"
EXT = (".png", ".jpg", ".jpeg")


@final
class FilteredWallpapers(LoggingMixIn, Operations):
    def __init__(self, source_dir: str, cache_dir: str):
        self.source = source_dir
        self.cache = cache_dir

    def _get_colours(self) -> list[str]:
        if not os.path.exists(STYLIX_PATH):
            raise RuntimeError("Stylix is missing.")

        with open(STYLIX_PATH, "r") as f:
            palette = json.load(f)  # pyright: ignore[reportAny]

        return [f"#{palette[f'base0{i:X}']}" for i in range(16)]

    def _full_source_path(self, partial: str):
        if partial.startswith("/"):
            partial = partial[1:]
        return os.path.join(self.source, partial)

    def _full_cache_path(self, partial: str):
        if partial.startswith("/"):
            partial = partial[1:]
        return os.path.join(self.cache, partial)

    def _full_target_path(self, partial: str):
        source = self._full_source_path(partial)
        cache = self._full_cache_path(partial)
        return (
            cache if partial.lower().endswith(EXT) and os.path.exists(cache) else source
        )

    def _ensure_cached(self, path: str):
        if not path.lower().endswith(EXT):
            return

        source_file = self._full_source_path(path)
        cache_file = self._full_cache_path(path)

        if not os.path.exists(cache_file) or os.path.getmtime(
            source_file
        ) > os.path.getmtime(cache_file):
            os.makedirs(os.path.dirname(cache_file), exist_ok=True)
            _ = subprocess.run(
                [
                    "lutgen",
                    "apply",
                    source_file,
                    "-o",
                    cache_file,
                    "--",
                    *self._get_colours(),
                ],
                check=True,
                capture_output=False,
            )

    def getattr(self, path: str, fh=None):  # pyright: ignore[reportUnknownParameterType, reportMissingParameterType, reportIncompatibleMethodOverride, reportImplicitOverride]
        self._ensure_cached(path)

        try:
            st = os.lstat(self._full_target_path(path))
        # ignore thunar noise
        except FileNotFoundError:
            raise FuseOSError(errno.ENOENT)

        return dict(
            (key, getattr(st, key))
            for key in (
                "st_atime",
                "st_ctime",
                "st_gid",
                "st_mode",
                "st_mtime",
                "st_nlink",
                "st_size",
                "st_uid",
            )
        )

    def readdir(self, path: str, fh):  # pyright: ignore[reportUnknownParameterType, reportMissingParameterType, reportIncompatibleMethodOverride, reportImplicitOverride]
        dirents = [".", ".."]
        if os.path.isdir(self._full_source_path(path)):
            dirents.extend(os.listdir(self._full_source_path(path)))
        for r in dirents:
            yield r

    def read(self, path: str, length: int, offset: int, fh=None):  # pyright: ignore[reportUnknownParameterType, reportMissingParameterType, reportIncompatibleMethodOverride, reportImplicitOverride]
        with open(self._full_target_path(path), "rb") as f:
            _ = f.seek(offset)
            return f.read(length)


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format="%(levelname)s:%(name)s:%(message)s")

    if len(sys.argv) != 4:
        logging.error("Usage: wallpaper-fuse <source> <mountpoint> <cache>")
        sys.exit(1)

    source, mountpoint, cache = sys.argv[1:4]

    # foreground=True is required for systemd 'simple' service type
    _ = FUSE(
        FilteredWallpapers(source, cache), mountpoint, nothreads=True, foreground=True
    )
