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
  nixpkgs.overlays = [(import ../overlays/undervolt.nix)];
  services.undervolt = {
    enable = true;
    coreOffset = -137;
    uncoreOffset = -95;
    turbo = 0;
    temp = 95;
    p1 = {
      limit = 95;
      window = 56;
    };
    p2 = {
      limit = 162;
      window = 28;
    };
  };
  specialisation.on-the-go.configuration = {
    system.nixos.tags = ["on-the-go"];
    services.undervolt = {
      turbo = lib.mkForce 1;
      temp = lib.mkForce 85;
      p1.limit = lib.mkForce 45;
      p2.limit = lib.mkForce 45;
      gpuOffset = lib.mkForce (-50);
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
      coreOffset = lib.mkForce 0;
      uncoreOffset = lib.mkForce 0;
      turbo = lib.mkForce 1;
      temp = lib.mkForce 95;
      p1.limit = lib.mkForce 45;
      p2.limit = lib.mkForce 45;
      gpuOffset = lib.mkForce 0;
    };
    systemd.services.undervolt-nvidia.enable = lib.mkForce false;
  };
}
