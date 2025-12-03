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
          autoload
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

      # idk why it's reversed but it works
      "PGUP" = "add chapter -1"; # for some reason this goes to the next chapter
      "PGDWN" = "add chapter 1"; # prev chapter
      "Ctrl+PGDWN" = "playlist-next"; # prev file
      "Ctrl+PGUP" = "playlist-prev"; # next file
    };
  };
}
