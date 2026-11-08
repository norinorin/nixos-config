{inputs, ...}: {
  flake-file.inputs.chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

  den.aspects.chaotic = {
    nixos = {config, ...}: {
      imports = [inputs.chaotic.nixosModules.default];
    };
  };
}
