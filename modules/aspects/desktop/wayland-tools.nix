{
  den.aspects.wayland-tools = {
    nixos = {pkgs, ...}: {
      # This is an overlay so I don't have to override it in multiple places
      nixpkgs.overlays = [
        (final: prev: {
          gamescope = prev.gamescope.overrideAttrs (old: {
            NIX_CFLAGS_COMPILE =
              (old.NIX_CFLAGS_COMPILE or []) ++ ["-fno-fast-math"];
          });
        })
      ];

      environment.systemPackages = with pkgs; [
        wl-clipboard
        wl-mirror
        wayland-utils
        cage
        grim
        gamescope
        slurp
      ];
    };
  };
}
