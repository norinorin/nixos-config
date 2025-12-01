{
  pkgs,
  config,
  ...
}: {
  home.file."Wallpapers" = {
    source = ./.;
    recursive = true;
  };

  systemd.user.services.wally = {
    Unit.Description = "Set wallpapers using swaybg";
    Install.WantedBy = ["graphical-session.target" "niri.service" "hyprland-session.target"];
    Service = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.swaybg}/bin/swaybg \
          -o HDMI-A-1 -i ${config.home.homeDirectory}/Wallpapers/dark-mountain.jpg \
          -o eDP-1    -i ${config.home.homeDirectory}/Wallpapers/tiger.jpg
      '';
    };
  };
}
