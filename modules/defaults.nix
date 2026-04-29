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

    homeManager = {config, ...}: {
      home.stateVersion = "25.11";
      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 4d --keep 3";
        # IMPORTANT: this assumes the repo is located in ~/Dotfiles
        flake = "${config.home.homeDirectory}/Dotfiles";
      };
    };
  };

  den.schema.user.classes = lib.mkDefault ["homeManager"];
  den.ctx.host.includes = [
    (import ../classes/otg.nix {inherit lib den;})
  ];
  den.ctx.user.includes = [den.provides.mutual-provider];
}
