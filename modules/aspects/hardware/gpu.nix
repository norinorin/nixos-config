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

        services.xserver.videoDrivers = ["nvidia" "modesetting"];
      };

      nixosOtg = {lib, ...}: {
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
    };
  };
}
