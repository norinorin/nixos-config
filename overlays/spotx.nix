# from https://github.com/oskardotglobal/.dotfiles/blob/722192203254d842f5a55b4d28267876ab7cdeae/overlays/spotx.nix
{pkgs-unstable}: final: prev: let
  spotx = prev.fetchurl {
    url = "https://github.com/SpotX-Official/SpotX-Bash/raw/ca98eef240cd26b90ff423a836229275d4a1594f/spotx.sh";
    hash = "sha256-sx9TzfJdPJqIRzIpzcpfHxXsQ1uJWTeTLs6bIq78HL4=";
  };
in {
  spotify = pkgs-unstable.spotify.overrideAttrs (old: {
    nativeBuildInputs =
      old.nativeBuildInputs
      ++ (with prev; [
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
  });
}
