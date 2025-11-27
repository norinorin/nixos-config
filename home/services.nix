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
  };
}
