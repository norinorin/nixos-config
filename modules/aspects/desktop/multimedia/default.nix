{den, ...}: {
  den.aspects.multimedia = {
    includes = [
      den.aspects.obs
      den.aspects.mpv
      den.aspects.winapps
      den.aspects.tricat
    ];

    homeManager = {
      pkgs,
      inputs,
      ...
    }: {
      home.packages = with pkgs; [
        qbittorrent
        audacity
        yt-dlp
        ffmpeg-full
        scrcpy
        calibre
        libreoffice
        pinta

        (obsidian.overrideAttrs (old: {
          nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.makeWrapper];

          postFixup =
            (old.postFixup or "")
            + ''
              wrapProgram $out/bin/obsidian \
                --set SSH_ASKPASS "${pkgs.seahorse}/libexec/seahorse/ssh-askpass" \
                --set SSH_ASKPASS_REQUIRE "force" \
                --set GIT_ASKPASS "${pkgs.seahorse}/libexec/seahorse/ssh-askpass"
            '';
        }))

        (
          # from https://github.com/oskardotglobal/.dotfiles/blob/722192203254d842f5a55b4d28267876ab7cdeae/overlays/spotx.nix
          pkgs.spotify.overrideAttrs (old: let
            spotx = pkgs.fetchurl {
              url = "https://raw.githubusercontent.com/SpotX-Official/SpotX-Bash/496309d7ca789c7e24c87f12f081d80ced115d48/spotx.sh";
              hash = "sha256-B+1VuC5GsaYaKK/tLl/iu+z9y3E/vc9JFgO3Q5BAtwY=";
            };
          in {
            nativeBuildInputs =
              old.nativeBuildInputs
              ++ (with pkgs; [
                util-linux
                perl
                unzip
                zip
                curl
              ]);

            unpackPhase =
              builtins.replaceStrings
              ["runHook postUnpack"]
              [
                ''
                  patchShebangs --build ${spotx}
                  runHook postUnpack
                ''
              ]
              old.unpackPhase;

            installPhase =
              builtins.replaceStrings
              ["runHook postInstall"]
              [
                ''
                  bash ${spotx} -f -P "$out/share/spotify"
                  runHook postInstall
                ''
              ]
              old.installPhase;
          })
        )
      ];
    };
  };
}
