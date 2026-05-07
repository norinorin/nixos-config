{inputs, ...}: {
  flake-file.inputs.nixcord.url = "github:FlameFlag/nixcord/dev";

  den.aspects.nixcord = {
    homeManager = {
      pkgs,
      nixcordPkgs,
      ...
    }: {
      imports = [inputs.nixcord.homeModules.nixcord];
      programs.nixcord = {
        enable = true;
        discord = {
          vencord.enable = false;
          equicord.enable = true;
          package = nixcordPkgs.discord.overrideAttrs (old: {
            nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.makeWrapper];

            postFixup =
              (old.postFixup or "")
              + ''
                wrapProgram $out/opt/Discord/Discord \
                  --prefix LD_LIBRARY_PATH : "/run/opengl-driver/lib"
              '';
          });
        };
        equibop.enable = true;
        config = {
          frameless = true;
          plugins = {
            alwaysTrust.enable = true;
            anonymiseFileNames.enable = true;
            betterAudioPlayer.enable = true;
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
