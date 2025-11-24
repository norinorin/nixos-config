{
  description = "NixOS config";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
        inputs.nixpkgs.follows = "nixpkgs";
      };
  };
  outputs = inputs @ { self, nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      toaster = let 
        username = "nori";
        specialArgs = { inherit username; };
      in
        nixpkgs.lib.nixosSystem {
          inherit specialArgs;

          modules = [
            ./nixos

            home-manager.nixosModules.home-manager
            { home-manager = {
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
