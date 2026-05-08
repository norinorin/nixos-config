{den, ...}: {
  den.aspects.boot = {
    includes = [den.aspects.rolling];
    nixos = {pkgs, ...}: {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.kernelPackages = pkgs.rolling.linuxPackages_xanmod_latest;
      boot.zswap = {
        enable = true;
        compressor = "zstd";
        zpool = "zsmalloc";
        maxPoolPercent = 30;
        shrinkerEnabled = true;
      };
      boot.initrd.systemd.enable = true;
      boot.kernel.sysctl = {
        "vm.swappiness" = 100;
        "vm.max_map_count" = 2147483642;
      };
      boot.supportedFilesystems = ["ntfs"];
    };
  };
}
