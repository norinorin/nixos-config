{inputs, ...}: {
  flake-file.inputs.nixcord.url = "github:kaylorben/nixcord";

  den.aspects.nixcord = {
    homeManager = {pkgs, ...}: {
      imports = [inputs.nixcord.homeModules.nixcord];
      programs.nixcord = {
        enable = true;
        discord = {
          vencord.enable = false;
          equicord.enable = true;
          package = inputs.nixcord.packages.${pkgs.stdenv.hostPlatform.system}.discord.overrideAttrs (old: {
            nativeBuildInputs =
              (old.nativeBuildInputs or []) ++ [pkgs.makeWrapper];

            # run it through steam-run because discord modules aren't patched
            # and that breaks hw-accelerated screensharing
            postFixup =
              (old.postFixup or "")
              + ''
                mv $out/opt/Discord/Discord $out/opt/Discord-unwrapped

                makeWrapper ${pkgs.steam-run}/bin/steam-run $out/opt/Discord/Discord \
                  --add-flags "$out/opt/Discord-unwrapped"
              '';
          });
        };
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
    };
  };
}
