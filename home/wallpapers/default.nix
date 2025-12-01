{
  pkgs,
  config,
  ...
}: {
  home.file."Wallpapers" = {
    source = ./.;
    recursive = true;
  };

  systemd.user.services.wally = let
    units = ["niri.service" "hyprland-session.target"];
  in {
    Unit = {
      Description = "Set wallpapers using swaybg";
      After = units;
      Wants = units;
      PartOf = units;
    };
    Install.WantedBy = units;
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
