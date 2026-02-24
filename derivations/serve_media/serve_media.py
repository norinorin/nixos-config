#!/usr/bin/env python3

import argparse
from dataclasses import dataclass
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import override
from urllib.parse import quote, unquote, urlparse

VIDEO_EXTENSIONS = {".mp4", ".mkv", ".avi", ".mov"}


@dataclass
class Args:
    port: int
    path: Path


parser = argparse.ArgumentParser("serve_media")
_ = parser.add_argument("--port", "-p", type=int, default=8000)
_ = parser.add_argument("path", default=Path.cwd().resolve(), type=Path)
args = parser.parse_args(namespace=Args)


class PlaylistHandler(SimpleHTTPRequestHandler):
    @override
    def do_GET(self):
        parsed = unquote(urlparse(self.path).path)

        if (
            parsed.endswith(".m3u8")
            and (dir := (args.path / parsed[:-5].lstrip("/")).resolve()).is_dir()
        ):
            return self._serve_playlist(dir)

        file_path = (args.path / parsed.lstrip("/")).resolve()
        if file_path.is_file() and file_path.suffix.lower() in VIDEO_EXTENSIONS:
            return self._serve_file_range(file_path)

        return super().do_GET()

    def _serve_playlist(self, dir: Path):
        host = self.headers.get("Host", "")
        playlist = ["#EXTM3U"]

        for file in sorted(dir.iterdir()):
            if file.suffix.lower() in VIDEO_EXTENSIONS:
                rel_path = file.relative_to(args.path)
                url_path = "/".join(quote(part) for part in rel_path.parts)
                url = f"http://{host}/{url_path}"

                playlist.append(f"#EXTINF:-1,{file.stem}")
                playlist.append(url)

        content = "\n".join(playlist).encode("utf-8")

        self.send_response(200)
        self.send_header("Content-Type", "application/x-mpegURL")
        self.send_header("Content-Length", str(len(content)))
        self.end_headers()
        try:
            _ = self.wfile.write(content)
        except ConnectionResetError:
            pass

    def _serve_file_range(self, path: Path):
        file_size = path.stat().st_size
        range_header = self.headers.get("Range")

        start = 0
        end = file_size - 1

        if range_header:
            range_str = range_header.strip().split("=")[-1]
            if "-" in range_str:
                start_str, end_str = range_str.split("-")
                if start_str:
                    start = int(start_str)
                if end_str:
                    end = int(end_str)
        length = end - start + 1

        with path.open("rb") as f:
            _ = f.seek(start)
            data = f.read(length)

        self.send_response(206 if range_header else 200)
        self.send_header("Content-Type", "application/octet-stream")
        self.send_header("Content-Length", str(length))
        self.send_header("Accept-Ranges", "bytes")
        if range_header:
            self.send_header("Content-Range", f"bytes {start}-{end}/{file_size}")
        self.end_headers()
        try:
            _ = self.wfile.write(data)
        except ConnectionResetError:
            pass


if __name__ == "__main__":
    print(f"Serving {args.path} at http://0.0.0.0:{args.port}")
    try:
        ThreadingHTTPServer(("0.0.0.0", args.port), PlaylistHandler).serve_forever()
    except KeyboardInterrupt:
        print("\nExiting...")
