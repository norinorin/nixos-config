{den, ...}: {
  den.aspects.wallpapers = {
    includes = [den.aspects.theme];

    homeManager = {
      config,
      pkgs,
      ...
    }: {
      home.file."Pictures/Wallpapers".source =
        config.lib.my.mkAspectSymlink "desktop/wallpapers";

      home.packages = [pkgs.lutgen];

      systemd.user.services.wallpaper-fuse = let
        pythonEnv = pkgs.python3.withPackages (ps: [ps.fusepy]);
      in {
        Unit = {
          Description = "Base16 FUSE Wallpaper Filter";
          After = ["graphical-session.target"];
        };

        Service = {
          Type = "simple";
          ExecStartPre = ''
            ${pkgs.coreutils}/bin/mkdir -p %h/WallpapersFiltered %h/.cache/wallpaper-fuse
          '';
          ExecStart = ''
            ${pythonEnv}/bin/python3 \
              %h/Wallpapers \
              %h/WallpapersFiltered \
              %h/.cache/wallpaper-fuse
          '';
          ExecStop = "${pkgs.fuse}/bin/fusermount -u %h/WallpapersFiltered";
          Restart = "on-failure";
        };

        Install = {
          WantedBy = ["default.target"];
        };
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
