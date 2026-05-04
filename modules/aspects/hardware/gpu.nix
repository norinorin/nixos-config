{
  den.aspects.gpu = {
    provides.nvidiaHybrid = {
      nixos = {
        config,
        pkgs,
        lib,
        ...
      }: {
        environment.systemPackages = [
          (pkgs.callPackage
            (pkgs.path + "/pkgs/tools/system/nvtop/build-nvtop.nix")
            {
              intel = true;
              nvidia = true;
            })
        ];

        # https://discourse.nixos.org/t/why-nixos-using-dgpu-instead-of-igpu/73973/2
        # dunno if this is still needed, but I'll just keep it here
        services.graphical-desktop.enable = true;

        boot.kernelParams = [
          "mem_sleep_default=deep"
        ];

        hardware = {
          nvidia = {
            open = true;
            powerManagement = {
              enable = true;
              finegrained = true;
            };
            prime = {
              offload.enable = true;
              offload.enableOffloadCmd = true;
              intelBusId = "PCI:0@0:2:0";
              nvidiaBusId = "PCI:1@0:0:0";
            };
            dynamicBoost.enable = true;
          };
          graphics = {
            enable = true;
            enable32Bit = true;
            extraPackages = [pkgs.intel-media-driver];
          };
        };

        services.xserver.videoDrivers = ["nvidia"];

        environment.sessionVariables = {
          LIBVA_DRIVER_NAME = "iHD";
        };
      };

      nixosOtg = {lib, ...}: {
        hardware.nvidia = {
          dynamicBoost.enable = lib.mkForce false;
        };
      };
    };
  };
}
