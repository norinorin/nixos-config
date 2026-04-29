{
  den.aspects.swayosd = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [swayosd]; # swayosd-client
      services.swayosd.enable = true;
      # had to do this cos graphical-session.target is wonky with ly
      systemd.user.services.swayosd = let
        usingSwayOSD = [
          "niri.service"
          # "hyprland-session.target"
        ];
      in {
        Unit = {
          After = usingSwayOSD;
          PartOf = usingSwayOSD;
        };
        Install.WantedBy = usingSwayOSD;
      };
    };
  };
}
