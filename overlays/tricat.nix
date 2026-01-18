# https://gist.github.com/norinorin/4b458d232a5634de8daa2ed65e472caa
final: prev: {
  tricat =
    prev.runCommand "tricat-0.1.0" {
      nativeBuildInputs = [prev.python3];
    } ''
      mkdir -p $out/bin

      cat > $out/bin/tricat <<'EOF'
      #!${prev.python3}/bin/python

      from __future__ import annotations

      import abc
      import argparse
      import re
      import shlex
      from typing import Any


      class Token(abc.ABC):
          @staticmethod
          @abc.abstractmethod
          def match(arg: str, states: dict[str, Any]) -> Token | bool | None: ...

          @staticmethod
          def evaluate(arg: str, states: dict[str, Any]) -> Token | bool | None:
              for cls in Token.__subclasses__():
                  if ret := cls.match(arg, states):
                      return ret


      class Fade(Token):
          PATTERN = re.compile(r"fade(in|out)-(\d*\.?\d+)s")

          def __init__(self, type: str, duration: str | float):
              self.type = type
              self.duration = float(duration)

          @staticmethod
          def match(arg: str, states: dict[str, Any]) -> Fade | None:
              if not (match := Fade.PATTERN.match(arg)):
                  return

              fade = Fade(*match.groups())
              prev = states["prev"]
              if prev is None and fade.type == "out":
                  # ignore fadeout if there's no prior segment
                  return None

              if isinstance(prev, Segment) and fade.type == "out":
                  prev.fadeout = fade

              return fade


      class Segment(Token):
          PATTERN = re.compile(
              r"((?:\d+:)?(?:\d+:)?(?:\d+\.)?\d+)?-((?:\d+:)?(?:\d+:)?(?:\d+\.)?\d+)?"
          )

          def __init__(
              self,
              id: int,
              media_id: int,
              path: str,
              start: str | None,
              end: str | None,
              vi: int,
              ai: int,
              si: int,
          ):
              self.id = id
              self.media_id = media_id
              self.fadein: Fade | None = None
              self.fadeout: Fade | None = None
              self.path = path
              self.start = Segment.timestamp2seconds(start)
              self.end = Segment.timestamp2seconds(end)

              # stream indexes
              self.vi = vi
              self.ai = ai
              self.si = si

          @staticmethod
          def match(arg: str, states: dict[str, Any]) -> Segment | None:
              if not (match := Segment.PATTERN.match(arg)):
                  return

              segment = Segment(
                  states["segment_id"],
                  states["media_id"],
                  states["path"],
                  *match.groups(),
                  vi=states["vi"],
                  ai=states["ai"],
                  si=states["si"],
              )

              if segment.start is None and segment.end is None:
                  return

              prev = states["prev"]
              if isinstance(prev, Fade) and prev.type == "in":
                  segment.fadein = prev

              states["segment_id"] += 1
              segments: list[Segment] = states["segments"]
              segments.append(segment)
              return segment

          @staticmethod
          def timestamp2seconds(arg: str | None) -> float | None:
              if not arg:
                  return None

              args = arg.split(":")[::-1]
              return sum(float(part) * (60**i) for i, part in enumerate(args))

          def _trim_filter(self, t: str) -> str:
              if not (self.start or self.end):
                  return ""

              if not self.start:
                  return f"{t}trim=end={self.end}"

              if not self.end:
                  return f"{t}trim=start={self.start}"

              return f"{t}trim={self.start}:{self.end}"

          def _fade_filters(self, t: str) -> str:
              filters: list[str] = []

              if self.fadein:
                  filters.append(f"{t}fade=t=in:d={self.fadein.duration}")

              if self.fadeout:
                  if not self.end:
                      # case where the end of segment isn't specified
                      # length is unknown
                      # cba to spawn ffprobe
                      filters.append(
                          f"{t}reverse,{t}fade=t=in:d={self.fadeout.duration},{t}reverse"
                      )
                  else:
                      filters.append(
                          f"{t}fade=t=out:st={self.end - (self.start or 0) - self.fadeout.duration}:d={self.fadeout.duration}"
                      )

              return ",".join(filters)

          def _get_filters(self, t: str) -> str:
              filters = [
                  self._trim_filter(t),
                  f"{t}setpts=PTS-STARTPTS",
                  self._fade_filters(t),
              ]
              return ",".join([i for i in filters if i])

          def __repr__(self) -> str:
              return repr(str(self))

          def __str__(self) -> str:
              args: list[str] = [self.path]
              if self.fadein:
                  args.append(f"fadein-{self.fadein.duration}s")

              args.append(f"{self.start or ''''}-{self.end or ''''}")

              if self.fadeout:
                  args.append(f"fadeout-{self.fadeout.duration}s")

              return " ".join(args)

          def _get_media_specifier(self, t: str) -> str:
              t = t or "v"

              if t == "v" and self.si > -1:
                  return f"[v{self.media_id}s{self.si}i{self.id}]"

              args: list[str] = [str(self.media_id), t]

              if i := getattr(self, f"{t}i"):
                  args.append(str(i))

              return f"[{':'.join(args)}]"

          def generate_filters(self) -> str:
              return ";".join(
                  [
                      f"{self._get_media_specifier(i)}{self._get_filters(i)}[{i or 'v'}{self.id}]"
                      for i in ("", "a")
                  ]
              )


      class StreamIndexer(Token):
          PATTERN = re.compile(r"(v|a|s)i-(\d+)")

          @staticmethod
          def match(arg: str, states: dict[str, Any]) -> bool | None:
              if not (match := StreamIndexer.PATTERN.match(arg)):
                  return

              t, i = match.groups()

              # invalid
              if not (t and i):
                  return

              states[f"{t}i"] = int(i)
              return True


      def _strip_comments(sources: list[str]) -> list[str]:
          if "#" not in sources:
              return sources

          return sources[: sources.index("#")]


      def get_sources_from_file(path: str) -> list[list[str]]:
          ret: list[list[str]] = []

          with open(path, "r", encoding="utf-8") as f:
              for line in f:
                  source = shlex.split(line)

                  # prevent infinite recursion reading the same file
                  if source and source[0] == path:
                      continue

                  ret.append(_strip_comments(source))

          return ret


      def parse_sources(sources: list[list[str]]) -> tuple[list[str], list[Segment]]:
          media_list: list[str] = []
          segments: list[Segment] = []
          # global states
          states: dict[str, Any] = {"segments": segments, "prev": None, "segment_id": 0}

          for source in sources:
              # ignore empty lines
              if not source:
                  continue

              path, *args = source

              # a reference to another text file
              if not args:
                  ml, s = parse_sources(get_sources_from_file(path))
                  media_list.extend(ml)
                  segments.extend(s)
                  continue

              if path not in media_list:
                  media_list.append(path)

              # source-specific states
              states["path"] = path
              states["media_id"] = media_list.index(path)
              states["vi"] = 0
              states["ai"] = 0
              states["si"] = -1  # -1 for absence

              for arg in args:
                  if token := Token.evaluate(arg, states):
                      if isinstance(token, Token):
                          states["prev"] = token
                      continue

                  raise SyntaxError(f"Invalid token: {arg!r}")

          if not segments:
              raise RuntimeError(f"Segments not found")

          return media_list, segments


      def _escape_path_in_filter(path: str) -> str:
          ESCAPE_CHAR = "\\\\\\"
          SPEC_CHARS = ("\\", "[", "]", "'", ":")

          for char in SPEC_CHARS:
              path = path.replace(char, f"{ESCAPE_CHAR}{char}")

          return path


      def generate_sub_filters(paths: dict[str, int], segments: list[Segment]) -> str:
          sub_ids: dict[str, dict[int, set[int]]] = {}
          for segment in segments:
              if segment.si == -1:
                  continue

              sub_ids.setdefault(segment.path, {}).setdefault(segment.si, set()).add(
                  segment.id
              )

          filters: list[str] = []
          for path, sis in sub_ids.items():
              media_id = paths[path]
              for si, segment_ids in sis.items():
                  is_single_segment = len(segment_ids) == 1
                  output_label = f"v{media_id}s{si}"
                  filters.append(
                      f'[{media_id}:v]subtitles="{_escape_path_in_filter(path)}":si={si}[{output_label}{f"i{[*segment_ids][0]}" * is_single_segment}]'
                  )
                  if not is_single_segment:
                      filters.append(
                          f"[{output_label}]split={len(segment_ids)}{''''.join([f'[{output_label}i{segment_id}]' for segment_id in segment_ids])}"
                      )

          return ";".join(filters)


      def generate_ffmpeg_args(
          media_list: list[str], segments: list[Segment], output: str
      ) -> str:
          paths = {v: i for i, v in enumerate(media_list)}
          args = ["ffmpeg"]

          for path in paths.keys():
              args.extend(["-i", f'"{path}"'])

          args.append("-filter_complex")

          filters: list[str] = []
          labels: list[str] = []

          if subs := generate_sub_filters(paths, segments):
              filters.append(subs)

          for i, segment in enumerate(segments):
              filters.append(segment.generate_filters())
              labels.append(f"[v{i}][a{i}]")

          filters.append(f"{''''.join(labels)}concat=n={len(segments)}:v=1:a=1[v][a]")
          args.extend([";".join(filters), "-map", "[v]", "-map", "[a]", f'"{output}"'])
          return " ".join(args)


      parser = argparse.ArgumentParser(
          "Tricat",
          "tricat.py <input video> <timestamps|fadeins/outs> [+ segments.txt] <output video>",
          "Generates FFmpeg filters",
      )
      parser.add_argument("-v", "--verbose", action="store_true")
      parser.add_argument(
          "sources",
          nargs="*",
          help='Sources are separated by "+" and each source consists of an input file followed by segments.'
          ' Segments are separated by spaces and formatted as "start-end" and you can omit one of the endpoints, e.g. "05:00-07:00," "5-6," "0-," "-5."',
      )
      parser.add_argument("output", help="The output file")


      def _split_args(args: list[str]) -> list[list[str]]:
          ret: list[list[str]] = []

          while 1:
              if "+" not in args:
                  ret.append(args)
                  break

              pi = args.index("+")
              ret.append(args[:pi])
              args = args[pi + 1 :]

          return ret


      def main():
          args = parser.parse_args()
          sources: list[list[str]] = _split_args(args.sources)
          media_list, segments = parse_sources(sources)
          if args.verbose:
              print("Found segments:", segments, end="\n\n")
          print(generate_ffmpeg_args(media_list, segments, args.output))


      if __name__ == "__main__":
          main()
      EOF

      chmod +x $out/bin/tricat
    '';
}
