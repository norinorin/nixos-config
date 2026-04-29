{
  lib,
  den,
  ...
}: {
  den.default = {
    nixos = {pkgs, ...}: {
      time.timeZone = "Asia/Jakarta";
      nix.settings.experimental-features = ["nix-command" "flakes"];
      environment.systemPackages = with pkgs; [git helix];
      system.stateVersion = "25.11";
      nixpkgs.config.allowUnfree = true;
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
      };
    };

    homeManager = {
      home.stateVersion = "25.11";
    };

    provides.to-users = {user, ...}: {
      homeManager = {
        programs.nh = {
          enable = true;
          clean.enable = true;
          clean.extraArgs = "--keep-since 4d --keep 3";
          flake = "/home/${user.userName}/Dotfiles";
        };
      };
    };
  };

  den.schema.user.classes = lib.mkDefault ["homeManager"];
  den.ctx.host.includes = [(import ../classes/otg.nix)];
  den.ctx.user.includes = [den.provides.mutual-provider];
}
