{
  den,
  lib,
  ...
}: {
  den.aspects.toaster = {
    nixos = {pkgs, ...}: {
      imports = [./_hardware-configuration.nix];

      # make HDMI-A-5 persistent
      # this fixes a bug in niri where the context menu in firefox
      # is rendered offscreen (invisible) after the connector HDMI-A-5
      # gets reinitialised on dpms off/on (which happens regularly on idle)
      boot.kernelParams = ["video=HDMI-A-5:e"];

      virtualisation.vmVariant = {
        imports = [(den.provides.tty-autologin "nori").nixos];

        boot.loader.grub.enable = false;
        boot.zswap.enable = lib.mkForce false;
        boot.resumeDevice = lib.mkForce "";
        fileSystems."/".device = "/dev/fake";
        fileSystems."/".fsType = "auto";
        services.swapspace.enable = lib.mkForce false;
        swapDevices = lib.mkForce [];
      };

      environment.sessionVariables = {
        "__GL_VidHeapReuseRatio" = 0;
      };
    };

    includes = with den.aspects; [
      fonts
      theme
      gaming

      # os
      audio
      audio._.denoiser
      boot
      gc
      hibernation
      swap
      tlp
      virt
      x11

      # desktop
      ly
      niri

      # hardware
      gpu._.nvidiaHybrid
      hotspot
      input
      intel
      monitors
      sensors
      sensors._.legion
      tablet
      undervolt._.nvidia
      undervolt._.intel

      # networking
      networking
      ssh
      zerotierone

      # security
      gnupg
      secureboot
      sops
    ];
  };
}
