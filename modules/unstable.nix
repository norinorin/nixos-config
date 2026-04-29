{inputs, ...}: {
  flake-file.inputs = {
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
  };

  den.aspects.unstable = {
    nixos = {config, ...}: {
      nixpkgs.overlays = [
        (final: prev: {
          unstable = import inputs.nixpkgs-unstable {
            inherit (prev.stdenv.hostPlatform) system;
            inherit (config.nixpkgs) config;
          };
        })
      ];
    };
  };
}
