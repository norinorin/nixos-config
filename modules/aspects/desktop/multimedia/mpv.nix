{
  den.aspects.mpv = {
    homeManager = {pkgs, ...}: {
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
              (autosub.overrideAttrs (oldAttrs: {
                preInstall =
                  oldAttrs.preInstall
                  + ''
                    substituteInPlace autosub.lua --replace-fail \
                      "{ 'Dutch', 'nl', 'dut' }," \
                      "{ 'Indonesian', 'id', 'ind' },"

                    substituteInPlace autosub.lua --replace-fail \
                      "auto = true" \
                      "auto = false"
                  '';
              }))
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

          "PGUP" = "add chapter -1"; # prev chapter
          "PGDWN" = "add chapter 1"; # next chapter
          "Ctrl+PGUP" = "playlist-prev"; # prev file
          "Ctrl+PGDWN" = "playlist-next"; # next file
        };
      };
    };
  };
}
