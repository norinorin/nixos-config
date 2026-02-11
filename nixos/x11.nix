{pkgs, ...}: {
  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
  };

  environment.systemPackages = with pkgs; [
    xsetroot
    xinit
    xrandr
  ];
}
