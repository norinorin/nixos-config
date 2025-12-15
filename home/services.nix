{inputs, ...}: {
  imports = [inputs.anime_rpc.homeModules.anime_rpc];

  services = {
    swayosd.enable = true;
    playerctld.enable = true;
    anime_rpc = {
      enable = true;
      enableWebserver = true;
      pollers = ["mpv-webui:14567" "mpc"];
      fetchEpisodeTitles = true;
    };
    swayidle.enable = true;
  };

  systemd.user.services.swayidle = let
    usingSwayIdle = ["niri.service"];
  in {
    Unit = {
      After = usingSwayIdle;
      PartOf = usingSwayIdle;
    };
    Install.WantedBy = usingSwayIdle;
  };

  # had to do this cos graphical-session.target is wonky with ly
  systemd.user.services.swayosd = let
    usingSwayOSD = ["niri.service" "hyprland-session.target"];
  in {
    Unit = {
      After = usingSwayOSD;
      PartOf = usingSwayOSD;
    };
    Install.WantedBy = usingSwayOSD;
  };
}
