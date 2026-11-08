import asyncio
import contextlib
import errno
import json
import logging
import os
import sys
from typing import final

import pyfuse3
import pyfuse3.asyncio

STYLIX_PATH = "/etc/stylix/palette.json"
EXT = (".png", ".jpg", ".jpeg")


@final
class FilteredWallpapers(pyfuse3.Operations):
    def __init__(self, source_dir: str, cache_dir: str):
        super().__init__()
        self.source = os.path.realpath(source_dir)
        self.cache = cache_dir

        self._inode_path_map: dict[int, str] = {pyfuse3.ROOT_INODE: "/"}
        self._path_inode_map: dict[str, int] = {"/": pyfuse3.ROOT_INODE}
        self._next_inode: int = pyfuse3.ROOT_INODE + 1
        self._lutgen_locks: dict[str, asyncio.Lock] = {}
        self._lookup_counts: dict[int, int] = {}
        self._next_fh: int = 1
        self._dir_snapshots: dict[int, tuple[int, list[str]]] = {}

    def _add_lookup(self, inode: int, count: int = 1):
        self._lookup_counts[inode] = self._lookup_counts.get(inode, 0) + count

    def _get_inode(self, path: str) -> int:
        if path in self._path_inode_map:
            return self._path_inode_map[path]
        inode = self._next_inode
        self._next_inode += 1
        self._path_inode_map[path] = inode
        self._inode_path_map[inode] = path
        return inode

    def _normalize_path(self, parent: str, name: str) -> str:
        if name == ".":
            return parent
        if name == "..":
            return os.path.dirname(parent.rstrip("/")) or "/"
        if not name or "/" in name or "\0" in name:
            raise pyfuse3.FUSEError(errno.EINVAL)
        return os.path.join(parent, name)

    def _get_path(self, inode: int) -> str:
        try:
            return self._inode_path_map[inode]
        except KeyError as e:
            raise pyfuse3.FUSEError(errno.ENOENT) from e

    def _get_colours(self) -> list[str]:
        if not os.path.exists(STYLIX_PATH):
            raise RuntimeError("Stylix is missing.")
        with open(STYLIX_PATH) as f:
            palette = json.load(f)
        return [f"#{palette[f'base0{i:X}']}" for i in range(16)]

    def _full_source_path(self, partial: str) -> str:
        partial = partial.removeprefix("/")
        target = os.path.join(self.source, partial)
        resolved = os.path.realpath(target)
        try:
            if os.path.commonpath([self.source, resolved]) != self.source:
                raise pyfuse3.FUSEError(errno.EACCES)  # Access Denied
        except ValueError as e:
            raise pyfuse3.FUSEError(errno.EACCES) from e
        return target

    def _full_cache_path(self, partial: str) -> str:
        partial = partial.removeprefix("/")
        return os.path.join(self.cache, partial)

    def _full_target_path(self, partial: str) -> str:
        source = self._full_source_path(partial)
        cache = self._full_cache_path(partial)
        return cache if partial.lower().endswith(EXT) and os.path.exists(cache) else source

    async def _ensure_cached(self, path: str):
        if not path.lower().endswith(EXT):
            return

        if path not in self._lutgen_locks:
            self._lutgen_locks[path] = asyncio.Lock()

        async with self._lutgen_locks[path]:
            source_file = self._full_source_path(path)
            cache_file = self._full_cache_path(path)

            if not os.path.lexists(source_file):  # noqa: ASYNC240
                raise pyfuse3.FUSEError(errno.ENOENT)

            if not os.path.exists(cache_file) or os.path.getmtime(source_file) > os.path.getmtime(  # noqa: ASYNC240
                cache_file
            ):
                os.makedirs(os.path.dirname(cache_file), exist_ok=True)
                process = await asyncio.create_subprocess_exec(
                    "lutgen",
                    "apply",
                    source_file,
                    "-o",
                    cache_file,
                    "--",
                    *self._get_colours(),
                    stdout=asyncio.subprocess.PIPE,
                    stderr=asyncio.subprocess.PIPE,
                )
                _, stderr = await process.communicate()

                if process.returncode != 0:
                    logging.error(
                        "lutgen failed for %s: %s", source_file, stderr.decode(errors="replace")
                    )
                    if os.path.exists(cache_file):  # noqa: ASYNC240
                        with contextlib.suppress(OSError):
                            os.remove(cache_file)

    async def lookup(self, inode_p: int, name: bytes, ctx=None):  # pyright: ignore[reportMissingParameterType, reportUnknownParameterType]
        name_str = os.fsdecode(name)
        parent_path = self._get_path(inode_p)
        path = self._normalize_path(parent_path, name_str)
        source_path = self._full_source_path(path)

        if not os.path.lexists(source_path):  # noqa: ASYNC240
            raise pyfuse3.FUSEError(errno.ENOENT)

        inode = self._get_inode(path)
        attr = await self.getattr(inode, ctx)
        self._add_lookup(inode)
        return attr

    async def getattr(self, inode: int, ctx=None):  # pyright: ignore[reportMissingParameterType, reportUnknownParameterType]
        path = self._get_path(inode)
        await self._ensure_cached(path)

        try:
            st = os.lstat(self._full_target_path(path))
        except FileNotFoundError as e:
            raise pyfuse3.FUSEError(errno.ENOENT) from e

        entry = pyfuse3.EntryAttributes()
        entry.st_ino = inode
        entry.generation = 0
        entry.entry_timeout = 0
        entry.attr_timeout = 0

        for attr in ("st_mode", "st_nlink", "st_uid", "st_gid", "st_rdev", "st_size"):
            setattr(entry, attr, getattr(st, attr))

        entry.st_blksize = st.st_blksize
        entry.st_blocks = st.st_blocks
        entry.st_atime_ns = st.st_atime_ns
        entry.st_mtime_ns = st.st_mtime_ns
        entry.st_ctime_ns = st.st_ctime_ns

        return entry

    async def opendir(self, inode: int, _ctx):
        path = self._get_path(inode)
        source_path = self._full_source_path(path)

        try:
            os.stat(source_path)
        except FileNotFoundError as e:
            raise pyfuse3.FUSEError(errno.ENOENT) from e

        if not os.path.isdir(source_path):  # noqa: ASYNC240
            raise pyfuse3.FUSEError(errno.ENOTDIR)

        entries = [".", ".."]
        entries.extend(os.listdir(source_path))

        fh = self._next_fh
        self._next_fh += 1
        self._dir_snapshots[fh] = (inode, entries)
        return fh

    async def readdir(self, fh: int, off: int, token):
        if fh not in self._dir_snapshots:
            return

        inode, entries = self._dir_snapshots[fh]
        path = self._get_path(inode)

        for i, name in enumerate(entries[off:]):
            child_path = self._normalize_path(path, name)
            child_inode = self._get_inode(child_path)
            try:
                attr = await self.getattr(child_inode)
            except pyfuse3.FUSEError:
                continue

            if not pyfuse3.readdir_reply(token, os.fsencode(name), attr, off + i + 1):
                break

            if name not in (".", ".."):
                self._add_lookup(child_inode)

    async def releasedir(self, fh: int):
        self._dir_snapshots.pop(fh, None)

    async def open(self, inode: int, flags: int, ctx):  # pyright: ignore[reportMissingParameterType, reportUnknownParameterType]
        if flags & os.O_ACCMODE != os.O_RDONLY:
            raise pyfuse3.FUSEError(errno.EROFS)
        return pyfuse3.FileInfo(fh=inode)

    async def read(self, fh: int, off: int, size: int):  # pyright: ignore[reportMissingParameterType, reportUnknownParameterType]
        path = self._get_path(fh)
        target_path = self._full_target_path(path)
        try:
            with open(target_path, "rb") as f:  # noqa: ASYNC230
                f.seek(off)
                return f.read(size)
        except OSError as e:
            raise pyfuse3.FUSEError(e.errno) from e

    async def forget(self, inode_list):
        for inode, nlookup in inode_list:
            remaining = self._lookup_counts.get(inode, 0) - nlookup
            if remaining > 0:
                self._lookup_counts[inode] = remaining
            else:
                self._lookup_counts.pop(inode, None)


async def main():
    logging.basicConfig(level=logging.INFO, format="%(levelname)s:%(name)s:%(message)s")

    if len(sys.argv) != 4:
        logging.error("Usage: wallpaper-fuse <source> <mountpoint> <cache>")
        sys.exit(1)

    source, mountpoint, cache = sys.argv[1:4]
    fs = FilteredWallpapers(source, cache)
    fuse_options = set(pyfuse3.default_options)
    fuse_options.add(f"fsname={os.path.basename(sys.argv[0])}")
    fuse_options.add("ro")
    pyfuse3.init(fs, mountpoint, fuse_options)

    try:
        await pyfuse3.main()
    finally:
        pyfuse3.close()


if __name__ == "__main__":
    pyfuse3.asyncio.enable()
    with contextlib.suppress(KeyboardInterrupt):
        asyncio.run(main())
