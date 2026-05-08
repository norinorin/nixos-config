{inputs, ...}: {
  flake-file.inputs.nixpkgs-rolling.url = "nixpkgs/nixos-unstable-small";

  den.aspects.rolling = {
    nixos = {config, ...}: {
      nixpkgs.overlays = [
        (final: prev: {
          rolling = import inputs.nixpkgs-rolling {
            inherit (prev.stdenv.hostPlatform) system;
            inherit (config.nixpkgs) config;
          };
        })
      ];
    };
  };
}
