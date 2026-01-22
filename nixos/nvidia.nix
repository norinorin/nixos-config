{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = [pkgs.nvtopPackages.nvidia];

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
    nvidia = {
      modesetting.enable = true;
      open = true;
      powerManagement = {
        enable = true;
        finegrained = false;
      };
      nvidiaSettings = true;
      dynamicBoost.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
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
