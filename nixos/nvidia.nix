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
        version = "580.105.08";
        sha256_64bit = "sha256-2cboGIZy8+t03QTPpp3VhHn6HQFiyMKMjRdiV2MpNHU=";
        sha256_aarch64 = "sha256-zLRCbpiik2fGDa+d80wqV3ZV1U1b4lRjzNQJsLLlICk=";
        openSha256 = "sha256-FGmMt3ShQrw4q6wsk8DSvm96ie5yELoDFYinSlGZcwQ=";
        settingsSha256 = "sha256-YvzWO1U3am4Nt5cQ+b5IJ23yeWx5ud1HCu1U0KoojLY=";
        persistencedSha256 = "sha256-qh8pKGxUjEimCgwH7q91IV7wdPyV5v5dc5/K/IcbruI=";

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
