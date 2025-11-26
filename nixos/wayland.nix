{pkgs, ...}: {
  xdg.portal.config = {
    common = {
      default = [
        "gtk"
      ];
    };
    niri = {
      default = [
        "gnome"
        "gtk"
      ];
      "org.freedesktop.impl.portal.Secret" = [
        "gnome-keyring"
      ];
    };
  };

  environment.systemPackages = [pkgs.swayosd];
  services.udev.packages = [pkgs.swayosd];

  systemd.services.swayosd-libinput-backend = {
    description = "SwayOSD LibInput backend for listening to certain keys like CapsLock, ScrollLock, VolumeUp, etc.";
    documentation = ["https://github.com/ErikReider/SwayOSD"];
    wantedBy = ["graphical.target"];
    partOf = ["graphical.target"];
    after = ["graphical.target"];

    serviceConfig = {
      Type = "dbus";
      BusName = "org.erikreider.swayosd";
      ExecStart = "${pkgs.swayosd}/bin/swayosd-libinput-backend";
      Restart = "on-failure";
    };
  };
}
