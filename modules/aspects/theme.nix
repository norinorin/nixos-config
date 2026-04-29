{inputs, ...}: {
  flake-file.inputs.stylix = {
    url = "github:nix-community/stylix/release-25.11";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.theme = {
    # TODO: decide whether theme should be host-specific or shared across
    # all systems.
    nixos = {pkgs, ...}: {
      imports = [inputs.stylix.nixosModules.stylix];

      stylix = {
        enable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest.yaml";
        autoEnable = true;
        opacity = {
          applications = 1.;
          desktop = 0.9;
          terminal = 0.9;
        };
        fonts.monospace = {
          name = "Azeret Mono";
          package = pkgs.azeret-mono;
        };
        polarity = "dark";
      };

      environment.systemPackages = [
        pkgs.bibata-cursors
      ];
    };
  };
}
