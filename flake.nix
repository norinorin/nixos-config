{
  description = "NixOS config";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord.url = "github:kaylorben/nixcord";
    hyprland.url = "github:hyprwm/Hyprland";
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    anime_rpc.url = "github:norinorin/anime_rpc";
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    stylix,
    ...
  }: {
    nixosConfigurations = {
      toaster = let
        username = "nori";
        desktop = "hyprland";
        specialArgs = {inherit inputs username desktop;};
      in
        nixpkgs.lib.nixosSystem {
          inherit specialArgs;

          modules = [
            stylix.nixosModules.stylix
            ./nixos
            {nixpkgs.overlays = [inputs.anime_rpc.overlays.default];}
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username} = import ./users/${username}.nix;
                backupFileExtension = "backup";
                extraSpecialArgs = inputs // specialArgs;
              };
            }
          ];
        };
    };
  };
}
