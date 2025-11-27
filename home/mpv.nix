{pkgs, ...}: {
  programs.mpv = {
    enable = true;

    package = (
      pkgs.mpv-unwrapped.wrapper {
        scripts = with pkgs.mpvScripts; [
          uosc
          sponsorblock
          thumbfast
          simple-mpv-webui
        ];

        mpv = pkgs.mpv-unwrapped.override {
          waylandSupport = true;
          ffmpeg = pkgs.ffmpeg-full;
        };
      }
    );

    config = {
      profile = "high-quality";
      ytdl-format = "bestvideo+bestaudio";
      cache-default = 4000000;
      input-ipc-server = "/tmp/mpvsocket";
      slang = "en";
      alang = "ja,en";
      save-position-on-quit = true;
    };

    scriptOpts = {
      thumbfast = {
        hwdec = "yes";
      };
      webui = {
        port = 14567;
        osd_logging = "no";
      };
    };

    bindings = {
      "Alt+RIGHT" = "seek 80"; # skip anime op
      "Alt+LEFT" = "seek -80";
      "Ctrl+PGDWN" = "playlist-next";
      "Ctrl+PGUP" = "playlist-prev";
    };
  };
}
