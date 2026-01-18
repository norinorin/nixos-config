{
  lib,
  pkgs,
  ...
}: let
  pythonEnv = pkgs.python3.withPackages (ps: [ps.nvidia-ml-py]);
  # https://www.reddit.com/r/linux_gaming/comments/1fm17ea/comment/lo7mo09
  undervoltScript = pkgs.writeScript "undervolt-nvidia" ''
    #!${pythonEnv}/bin/python
    from pynvml import *
    from ctypes import byref

    nvmlInit()

    device = nvmlDeviceGetHandleByIndex(0)
    nvmlDeviceSetGpuLockedClocks(device, 405, 2100)

    # not supported in my setup
    # nvmlDeviceSetPowerManagementLimit(device, 95000)

    info = c_nvmlClockOffset_t()
    info.version = nvmlClockOffset_v1
    info.type = NVML_CLOCK_GRAPHICS
    info.pstate = NVML_PSTATE_0
    info.clockOffsetMHz = 75 # conservative, cba stress testing it

    nvmlDeviceSetClockOffsets(device, byref(info))

    nvmlShutdown()
  '';
in {
  boot.kernelModules = ["msr"];
  services.undervolt = {
    enable = lib.mkDefault true;
    coreOffset = lib.mkDefault (-137);
    uncoreOffset = lib.mkDefault (-95);
    analogioOffset = lib.mkDefault (-45);
    turbo = lib.mkDefault 0;
    temp = lib.mkDefault 95;
    p1 = lib.mkDefault {
      limit = 95;
      window = 56;
    };
    p2 = lib.mkDefault {
      limit = 162;
      window = 28;
    };
  };
  specialisation.on-the-go.configuration = {
    system.nixos.tags = ["on-the-go"];
    services.undervolt = {
      turbo = 1;
      coreOffset = -95;
      uncoreOffset = -55;
      temp = 85;

      # likely will still be 45
      p1.limit = 20;
      p2.limit = 20;

      gpuOffset = -50;
    };
  };
  systemd.services.undervolt-nvidia = {
    enable = true;
    description = "Undervolt the first available Nvidia GPU device";
    wantedBy = ["graphical.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [undervoltScript];
    };
  };
  specialisation.no-undervolt.configuration = {
    system.nixos.tags = ["no-undervolt"];
    services.undervolt = {
      coreOffset = 0;
      uncoreOffset = 0;
      analogioOffset = 0;
      turbo = 1;
      temp = 95;
      p1.limit = 45;
      p2.limit = 45;
      gpuOffset = 0;
    };
    systemd.services.undervolt-nvidia.enable = lib.mkForce false;
  };
}
