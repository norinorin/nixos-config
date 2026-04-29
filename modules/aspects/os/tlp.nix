{
  den,
  inputs,
  ...
}: {
  den.aspects.tlp = {
    includes = [den.aspects.unstable];

    nixos = {pkgs, ...}: {
      disabledModules = [
        "services/hardware/tlp.nix"
      ];

      imports = [
        "${inputs.nixpkgs-unstable}/nixos/modules/services/hardware/tlp.nix"
      ];

      services.tlp = {
        enable = true;
        pd = {
          enable = true;
          package = pkgs.unstable.tlp-pd;
        };
        settings = {
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

          CPU_MIN_PERF_ON_AC = 0;
          CPU_MAX_PERF_ON_AC = 100;
          CPU_MIN_PERF_ON_BAT = 0;
          CPU_MAX_PERF_ON_BAT = 20;

          SOUND_POWER_SAVE_ON_AC = 0;
          SOUND_POWER_SAVE_ON_BAT = 1;

          PLATFORM_PROFILE_ON_AC = "balance";
          PLATFORM_PROFILE_ON_BAT = "low-power";

          RUNTIME_PM_ON_AC = "on";
          RUNTIME_PM_ON_BAT = "auto";
          PCIE_ASPM_ON_AC = "default";
          PCIE_ASPM_ON_BAT = "powersupersave";
        };
      };
    };
  };
}
