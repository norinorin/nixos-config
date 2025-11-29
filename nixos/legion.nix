{config}: {
  # i only need the sensors
  boot.extraModulePackages = with config.boot.kernelPackages; [lenovo-legion-module];
  boot.kernelModules = [
    "lenovo-legion-module"
  ];
}
