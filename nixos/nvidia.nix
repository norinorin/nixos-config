{
  config,
  pkgs,
  ...
}: {
  # https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Changing_suspend_method
  # set suspend method to s2idle for suspend to work
  boot.kernelParams = [
    "nvidia-modeset.hdmi_deepcolor=0"
    "mem_sleep_default=s2idle" # on deep internal display won't turn on!
  ];

  # s2idle
  systemd.sleep.extraConfig = ''
    SuspendState=freeze
  '';

  boot.extraModprobeConfig = ''
    options nvidia_modeset vblank_sem_control=0
  '';

  hardware = {
    nvidia = let
      gpl_symbols_linux_617_patch = pkgs.fetchpatch {
        url = "github.com/CachyOS/kernel-patches/raw/refs/heads/master/6.17/misc/nvidia/0003-Workaround-nv_vm_flags_-calling-GPL-only-code.patch";
        hash = "sha256-YOTAvONchPPSVDP9eJ9236pAPtxYK5nAePNtm2dlvb4=";
        stripLen = 1;
        extraPrefix = "kernel/";
      };

      nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "580.95.05";
        sha256_64bit = "sha256-hJ7w746EK5gGss3p8RwTA9VPGpp2lGfk5dlhsv4Rgqc=";
        sha256_aarch64 = "sha256-zLRCbpiik2fGDa+d80wqV3ZV1U1b4lRjzNQJsLLlICk=";
        openSha256 = "sha256-RFwDGQOi9jVngVONCOB5m/IYKZIeGEle7h0+0yGnBEI=";
        settingsSha256 = "sha256-F2wmUEaRrpR1Vz0TQSwVK4Fv13f3J9NJLtBe4UP2f14=";
        persistencedSha256 = "sha256-QCwxXQfG/Pa7jSTBB0xD3lsIofcerAWWAHKvWjWGQtg=";

        patches = [gpl_symbols_linux_617_patch];
      };
    in {
      modesetting.enable = true;
      open = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      nvidiaSettings = true;
      package = nvidiaPackage;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  services.xserver.videoDrivers = ["nvidia"];

  systemd.services."systemd-suspend" = {
    serviceConfig = {
      Environment = ''"SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=false"'';
    };
  };
}
