{
  description = "NixOS config";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:kaylorben/nixcord";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };
  };
  outputs = inputs @ { self, nixpkgs, home-manager, stylix, ... }: {
    nixosConfigurations = {
      toaster = let 
        username = "nori";
        desktop = "hyprland";
        specialArgs = { inherit inputs username desktop; };
      in
        nixpkgs.lib.nixosSystem {
          inherit specialArgs;

          modules = [
            stylix.nixosModules.stylix
            ./nixos
            home-manager.nixosModules.home-manager
            { home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username} = import ./users/${username}.nix;
                backupFileExtension = "backup";
                extraSpecialArgs = inputs // specialArgs;
                sharedModules = [
                  inputs.nixcord.homeModules.nixcord
                ];
              };
            }
          ];
        };
    };
  };
}
