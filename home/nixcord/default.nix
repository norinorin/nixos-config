{
  inputs,
  pkgs,
  ...
}: let
  patchedIndex = ./index.js;
in {
  imports = [inputs.nixcord.homeModules.nixcord];
  programs.nixcord = {
    enable = true;
    discord = {
      vencord.enable = true;
      package = inputs.nixcord.packages.${pkgs.stdenv.hostPlatform.system}.discord.overrideAttrs (old: {
        nativeBuildInputs =
          (old.nativeBuildInputs or []) ++ [pkgs.makeWrapper];

        # https://www.reddit.com/r/linux_gaming/comments/1s2l0pj/discord_nvidia_hardwareaccelerated_screen_sharing/
        # there should be a better way of doing this
        postFixup =
          (old.postFixup or "")
          + ''
            mv $out/bin/Discord $out/bin/Discord-pre-steam

            makeWrapper ${pkgs.steam-run}/bin/steam-run $out/bin/Discord \
              --add-flags "$out/bin/Discord-pre-steam" \
              --run '
                echo "[discord-nvenc] Checking patch..."

                CONFIG="$HOME/.config/discord"

                if [ -d "$CONFIG" ]; then
                  latest=$(find "$CONFIG" -maxdepth 1 -type d -name "0.*" \
                    -printf "%T@ %p\n" 2>/dev/null \
                    | sort -nr | head -n1 | cut -d" " -f2-)

                  if [ -n "$latest" ]; then
                    voice="$latest/modules/discord_voice"
                    target="$voice/index.js"

                    if [ -f "$target" ]; then
                      if ! cmp -s ${patchedIndex} "$target"; then
                        echo "[discord-nvenc] Patching $target"
                        cp ${patchedIndex} "$target"
                      fi

                      for f in gpu_encoder_helper discord_voice.node; do
                        if [ -f "$voice/$f" ]; then
                          chmod +x "$voice/$f"
                        fi
                      done
                    fi
                  fi
                fi
              '
          '';
      });
    };
    vesktop.enable = true;
    config = {
      frameless = true;
      plugins = {
        alwaysTrust.enable = true;
        anonymiseFileNames.enable = true;
        # betterAudioPlayer.enable = true;
        disableCallIdle.enable = true;
        experiments.enable = true;
        fakeNitro = {
          enable = true;
          enableEmojiBypass = false;
          enableStickerBypass = false;
          enableStreamQualityBypass = true;
        };
        fixSpotifyEmbeds.enable = true;
        fixYoutubeEmbeds.enable = true;
        gameActivityToggle.enable = true;
        messageLatency.enable = true;
        messageLogger.enable = true;
        relationshipNotifier.enable = true;
        silentTyping.enable = true;
        platformIndicators = {
          enable = true;
          showBots = true;
        };
        biggerStreamPreview.enable = true;
        customIdle = {
          enable = true;
          remainInIdle = true;
        };
        webScreenShareFixes.enable = true;
      };
    };
  };
}
