{inputs, ...}: {
  flake-file.inputs.anime_rpc = {
    url = "github:norinorin/anime_rpc";
    inputs.nixpkgs.follows = "nixpkgs-rolling";
    };

  den.aspects.anime_rpc = {
    nixos = {
      nixpkgs.overlays = [inputs.anime_rpc.overlays.default];
    };

    homeManager = {
      imports = [inputs.anime_rpc.homeModules.anime_rpc];

      programs.anime_rpc = {
        enable = true;
        ui.enable = true;
        settings = {
          webserver.enable = true;
          pollers = {
            mpvWebui = {
              enable = true;
              port = 14567;
            };
            mpc.enable = true;
          };
          fetchEpisodeTitles = true;
        };
      };
    };

    homeManagerOtg = {lib, ...}: {
      systemd.user.services.anime_rpc = lib.mkForce {};
    };
  };
}
