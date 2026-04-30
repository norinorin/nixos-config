{inputs, ...}: {
  flake-file.inputs.anime_rpc.url = "github:norinorin/anime_rpc";

  den.aspects.anime_rpc = {
    nixos = {
      nixpkgs.overlays = [inputs.anime_rpc.overlays.default];
    };

    homeManager = {
      imports = [inputs.anime_rpc.homeModules.anime_rpc];

      services.anime_rpc = {
        enable = true;
        enableWebserver = true;
        enableUI = true;
        pollers = ["mpv-webui:14567" "mpc"];
        fetchEpisodeTitles = true;
      };
    };

    homeManagerOtg = {lib, ...}: {
      services.anime_rpc.enable = lib.mkForce false;
    };
  };
}
