{
  config,
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = [pkgs.nvtopPackages.nvidia];

  boot.kernelParams = [
    "mem_sleep_default=deep"
  ];

  hardware = {
    nvidia = {
      modesetting.enable = true;
      open = true;
      powerManagement = {
        enable = true;
        finegrained = false;
      };
      prime = {
        sync.enable = true;
        intelBusId = "PCI:0@0:2:0";
        nvidiaBusId = "PCI:1@0:0:0";
      };
      nvidiaSettings = true;
      dynamicBoost.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  specialisation.on-the-go.configuration = {
    hardware.nvidia = {
      dynamicBoost.enable = lib.mkForce false;
      powerManagement.finegrained = lib.mkForce true;
      prime = {
        offload.enable = lib.mkForce true;
        offload.enableOffloadCmd = lib.mkForce true;
        sync.enable = lib.mkForce false;
      };
    };
  };

  services.xserver.videoDrivers = ["nvidia" "modesetting"];
}
