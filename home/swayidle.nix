# used by: niri
{
  pkgs,
  lib,
  ...
}: {
  services.swayidle = let
    lock = "${pkgs.swaylock}/bin/swaylock --daemonize";
    display = status: "${pkgs.niri}/bin/niri msg action power-${status}-monitors";
  in {
    enable = lib.mkDefault false;
    timeouts = [
      {
        timeout = 295; # in seconds
        command = "${pkgs.libnotify}/bin/notify-send 'Locking in 5 seconds' -t 5000";
      }
      {
        timeout = 300;
        command = lock;
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = (display "off") + "; " + lock;
      }
      {
        event = "after-resume";
        command = display "on";
      }
      {
        event = "lock";
        command = (display "off") + "; " + lock;
      }
      {
        event = "unlock";
        command = display "on";
      }
    ];
  };
}
