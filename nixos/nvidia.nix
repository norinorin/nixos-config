{...}: {
  boot.kernelParams = [
    "nvidia-modeset.hdmi_deepcolor=0"
    "nvidia-drm.fbdev=1"
  ];

  hardware = {
    nvidia = {
      modesetting.enable = true;
      open = true;
      powerManagement.enable = true;
    };
    graphics.enable = true;
  };

  services.xserver.videoDrivers = ["nvidia"];
}
