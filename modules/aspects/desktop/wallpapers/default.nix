{den, ...}: {
  den.aspects.wallpapers = {
    homeManager = {
      home.file."Pictures/Wallpapers" = {
        source = ./.;
        recursive = true;
      };
    };
  };

  den.aspects.wally = {
    includes = [den.aspects.wallpapers];

    homeManager = {
      pkgs,
      config,
      ...
    }: {
      systemd.user.services.wally = let
        units = [
          "niri.service"
          # "hyprland-session.target"
        ];
      in {
        Unit = {
          Description = "Set wallpapers using swaybg";
          After = units;
          PartOf = units;
        };
        Install.WantedBy = units;
        # TODO: make options for these
        Service = {
          Type = "simple";
          ExecStart = ''
            ${pkgs.swaybg}/bin/swaybg \
              -o HDMI-A-1 -i ${config.home.homeDirectory}/Wallpapers/liquid_abstract.jpg \
              -o HDMI-A-5 -i ${config.home.homeDirectory}/Wallpapers/liquid_abstract.jpg \
              -o eDP-1    -i ${config.home.homeDirectory}/Wallpapers/facade_arch_relief.jpg
          '';
        };
      };
    };
  };
}
