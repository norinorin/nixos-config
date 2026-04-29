{
  den.aspects.x11 = {
    nixos = {pkgs, ...}: {
      specialisation.x11.configuration = {
        system.nixos.tags = ["x11"];
        services.xserver = {
          enable = true;
          autoRepeatDelay = 200;
          autoRepeatInterval = 35;
          desktopManager = {
            xfce.enable = true;
          };
        };

        environment.systemPackages = with pkgs; [
          xsetroot
          xrandr
        ];
      };
    };
  };
}
