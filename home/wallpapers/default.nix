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
      PartOf = units;
    };
    Install.WantedBy = units;
    Service = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.swaybg}/bin/swaybg \
          -o HDMI-A-1 -i ${config.home.homeDirectory}/Wallpapers/liquid_abstract.jpg \
          -o eDP-1    -i ${config.home.homeDirectory}/Wallpapers/facade_arch_relief.jpg
      '';
    };
  };
}
