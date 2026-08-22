# TODO: figure out an api for a multi-host setup
{
  den.aspects.undervolt = {
    provides.nvidia = {
      nixos = {
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
        systemd.services.undervolt-nvidia = {
          enable = true;
          description = "Undervolt the first available Nvidia GPU device";
          wantedBy = ["graphical.target"];
          serviceConfig = {
            Type = "oneshot";
            # ignore failures
            ExecStart = ["-${undervoltScript}"];
          };
        };

        specialisation.no-undervolt.configuration = {
          systemd.services.undervolt-nvidia.enable = lib.mkForce false;
        };
      };
    };
  };
}
