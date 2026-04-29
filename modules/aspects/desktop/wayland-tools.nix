{
  den.aspects.wayland-tools = {
    nixos = {
      # This is an overlay so I don't have to override it in multiple places
      nixpkgs.overlays = [
        (final: prev: {
          gamescope = prev.gamescope.overrideAttrs (old: {
            NIX_CFLAGS_COMPILE =
              (old.NIX_CFLAGS_COMPILE or []) ++ ["-fno-fast-math"];
          });
        })
      ];
    };

    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        wl-clipboard
        wayland-utils
        cage
        grim
        gamescope
      ];
    };
  };
}
