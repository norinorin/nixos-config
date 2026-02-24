#!/usr/bin/env python3

import argparse
import os
import sys
from dataclasses import dataclass
from functools import partial
from html import escape
from http import HTTPStatus
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from io import BytesIO
from pathlib import Path, PurePosixPath
from typing import override
from urllib.parse import quote, unquote, urlparse

VIDEO_EXTENSIONS = {".mp4", ".mkv", ".avi", ".mov"}


@dataclass
class Args:
    port: int
    path: Path


parser = argparse.ArgumentParser("serve_media")
_ = parser.add_argument("--port", "-p", type=int, default=8000)
_ = parser.add_argument("path", default=Path.cwd().resolve(), nargs="?", type=Path)
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

        file_path = Path(self.translate_path(parsed))
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

    @override
    def list_directory(self, path: str | os.PathLike[str]) -> BytesIO | None:
        # copied from https://github.com/python/cpython/blob/fd0400585eb957c7d10812d87a8cb9e1f3c72519/Lib/http/server.py#L817C1-L868C17
        try:
            paths = os.listdir(path)
        except OSError:
            self.send_error(HTTPStatus.NOT_FOUND, "No permission to list directory")
            return None
        paths.sort(key=lambda a: a.lower())
        r: list[str] = []
        displaypath = self.path
        displaypath = displaypath.split("#", 1)[0]
        displaypath = displaypath.split("?", 1)[0]
        try:
            displaypath = unquote(displaypath, errors="surrogatepass")
        except UnicodeDecodeError:
            displaypath = unquote(displaypath)
        displaypath = escape(displaypath, quote=False)
        enc = sys.getfilesystemencoding()
        title = f"Directory listing for {displaypath}"
        r.append("<!DOCTYPE HTML>")
        r.append('<html lang="en">')
        r.append("<head>")
        r.append(f'<meta charset="{enc}">')
        r.append(
            '<style type="text/css">\n:root {\ncolor-scheme: light dark;\n}\n</style>'
        )
        r.append(f"<title>{title}</title>\n</head>")
        r.append(f"<body>\n<h1>{title}</h1>")
        r.append("<hr>\n<ul>")
        url_path = PurePosixPath(urlparse(self.path).path)
        if url_path != PurePosixPath("/"):
            parent = str(url_path.parent)
            parent += "/" * (not parent.endswith("/"))
            r.append(f'<li><a href="{parent}">../</a></li>')
        if any(Path(name).suffix.lower() in VIDEO_EXTENSIONS for name in paths):
            playlist_path = displaypath.rstrip("/") + ".m3u8"
            playlist_name = playlist_path.rstrip("/").split("/")[-1]
            r.append(
                f'<li><a href="{quote(playlist_path)}">{escape(playlist_name)}</a></li>\n'
            )
        for name in paths:
            fullname = os.path.join(path, name)
            displayname = linkname = name
            if os.path.isdir(fullname):
                displayname = name + "/"
                linkname = name + "/"
            if os.path.islink(fullname):
                displayname = name + "@"
            r.append(
                '<li><a href="%s">%s</a></li>'
                % (
                    quote(linkname, errors="surrogatepass"),
                    escape(displayname, quote=False),
                )
            )
        r.append("</ul>\n<hr>\n</body>\n</html>\n")
        encoded = "\n".join(r).encode(enc, "surrogateescape")
        f = BytesIO()
        _ = f.write(encoded)
        _ = f.seek(0)
        self.send_response(HTTPStatus.OK)
        self.send_header("Content-type", "text/html; charset=%s" % enc)
        self.send_header("Content-Length", str(len(encoded)))
        self.end_headers()
        return f


if __name__ == "__main__":
    print(f"Serving {args.path} at http://0.0.0.0:{args.port}")
    try:
        handler = partial(PlaylistHandler, directory=str(args.path))
        ThreadingHTTPServer(("0.0.0.0", args.port), handler).serve_forever()
    except KeyboardInterrupt:
        print("\nExiting...")
