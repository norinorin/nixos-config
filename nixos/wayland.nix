{ config, pkgs, lib, ... }: {
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  
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
}