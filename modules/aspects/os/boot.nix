{
  inputs,
  den,
  ...
}: {
  den.aspects.boot = {
    nixos = {pkgs, ...}: {
      imports = ["${inputs.nixpkgs-unstable}/nixos/modules/system/boot/zswap.nix"];

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.kernelPackages = pkgs.linuxPackages_zen;
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

    includes = [den.aspects.unstable];
  };
}
