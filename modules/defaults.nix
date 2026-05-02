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

    homeManager = {config, ...}: let
      cfg = config;
    in {
      options = {
        dotfilesDirectory = lib.mkOption {
          type = lib.types.str;
          default = "${cfg.home.homeDirectory}/Dotfiles";
          example = "${cfg.home.homeDirectory}/Dotfiles";
        };
      };

      config = {
        home.stateVersion = "25.11";
        programs.nh = {
          enable = true;
          clean.enable = true;
          clean.extraArgs = "--keep-since 4d --keep 3";
          flake = "${cfg.dotfilesDirectory}";
        };
        lib.my.mkAspectSymlink = path: cfg.lib.file.mkOutOfStoreSymlink "${cfg.dotfilesDirectory}/modules/aspects/${path}";
      };
    };
  };

  den.schema.user.classes = lib.mkDefault ["homeManager"];
  den.ctx.user.includes = [den.provides.mutual-provider];
}
