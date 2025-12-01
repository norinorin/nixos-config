{
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

  systemd.user.services.swayidle = {
    Unit = {
      Wants = ["niri.service"];
      After = ["niri.service"];
      PartOf = ["niri.service"];
    };
  };
}
