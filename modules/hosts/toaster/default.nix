{
  den,
  lib,
  ...
}: {
  den.aspects.toaster = {
    nixos = {pkgs, ...}: {
      imports = [./_hardware-configuration.nix];

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
      niri._.nvidia

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
