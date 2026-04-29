{
  den.aspects.sensors = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        lm_sensors
      ];
    };

    provides.legion = {
      nixos = {config, ...}: {
        boot.extraModulePackages = with config.boot.kernelPackages; [lenovo-legion-module];

        boot.kernelModules = [
          "lenovo-legion-module"
        ];
      };
    };
  };
}
