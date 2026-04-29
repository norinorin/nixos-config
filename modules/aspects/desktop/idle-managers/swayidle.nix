{den, ...}: {
  den.aspects.swayidle = {
    includes = [den.aspects.swaylock];

    homeManager = {
      pkgs,
      lib,
      config,
      ...
    }: {
      services.swayidle = let
        lock = "${pkgs.swaylock}/bin/swaylock --daemonize";
        display = status: "${config.programs.niri.package}/bin/niri msg action power-${status}-monitors";
      in {
        enable = true;
        timeouts = [
          {
            timeout = 300;
            command = display "off";
          }
          {
            timeout = 310;
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
        ];
      };

      systemd.user.services.swayidle = let
        usingSwayIdle = ["niri.service"];
      in {
        Unit = {
          After = usingSwayIdle;
          PartOf = usingSwayIdle;
        };
        Install.WantedBy = usingSwayIdle;
      };
    };
  };
}
