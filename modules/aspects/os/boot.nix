{den, ...}: {
  den.aspects.boot = {
    includes = [den.aspects.chaotic];
    nixos = {pkgs, ...}: {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.kernelPackages = pkgs.linuxPackages_cachyos;
      boot.zswap = {
        enable = true;
        compressor = "zstd";
        zpool = "zsmalloc";
        maxPoolPercent = 30;
        shrinkerEnabled = true;
      };
      boot.kernel.sysctl = {
        "vm.swappiness" = 100;
        "vm.max_map_count" = 2147483642;
      };
      boot.supportedFilesystems = ["ntfs"];

      # https://nixos.wiki/wiki/JACK#System_optimizations_for_low_latency_audio_with_JACK
      # https://bbs.archlinux.org/viewtopic.php?pid=2083341#p2083341
      boot.postBootCommands = ''
        echo 2048 > /sys/class/rtc/rtc0/max_user_freq
        echo 2048 > /proc/sys/dev/hpet/max-user-freq
      '';

      services.scx-loader = {
        enable = true;
        config = {
          default_sched = "scx_lavd";
          default_mode = "Gaming";
          scheds.scx_lavd = {
            gaming_mode = [
              "--performance"
              "--pinned-slice-us"
              "500"
            ];
            powersave_mode = [
              "--powersave"
              "--pinned-slice-us"
              "500"
            ];
          };
        };
      };
    };

    nixosOtg = {lib, ...}: {
      services.scx-loader.config.default_mode = lib.mkForce "PowerSave";
    };
  };
}
