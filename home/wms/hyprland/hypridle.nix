{pkgs, ...}: {
  services.hypridle = let
    swaylock = "${pkgs.swaylock}/bin/swaylock --daemonize";
    monitor = "${pkgs.hyprland}/bin/hyprctl dispatch dpms";
  in {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd = "${monitor} on";
        ignore_dbus_inhibit = false;
        lock_cmd = "${swaylock}";
      };

      listener = [
        {
          timeout = 420;
          on-timeout = "${swaylock}";
        }
        {
          timeout = 300;
          on-timeout = "${monitor} off";
          on-resume = "${monitor} on";
        }
      ];
    };
  };
}
