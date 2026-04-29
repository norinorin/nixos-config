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
          pkgs.unstable.spotify.overrideAttrs (old: let
            spotx = pkgs.fetchurl {
              url = "https://github.com/SpotX-Official/SpotX-Bash/raw/ca98eef240cd26b90ff423a836229275d4a1594f/spotx.sh";
              hash = "sha256-sx9TzfJdPJqIRzIpzcpfHxXsQ1uJWTeTLs6bIq78HL4=";
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
