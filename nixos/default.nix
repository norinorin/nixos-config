{
  config,
  pkgs,
  inputs,
  lib,
  displayManager,
  ...
}: let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    inherit (config.nixpkgs) config;
  };
in {
  _module.args.pkgsUnstable = pkgsUnstable;

  imports = [
    ./hardware-configuration.nix
    ./gc.nix
    ./fonts.nix
    ./nvidia.nix
    ./wayland.nix
    ./theme.nix
    # ./x11.nix
    ./undervolt.nix
    ./tablet.nix
    ./hibernation.nix
    ./legion.nix
    ./monitors.nix
    ./secureboot.nix
    ./audio.nix
    ./ime.nix
    ./overlays.nix
    ./gaming.nix

    (import ../modules {inherit config lib pkgs inputs displayManager;})
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgsUnstable.linuxPackages_zen;
  boot.kernelParams = [
    "zswap.enabled=1"
    "zswap.compressor=lz4"
    "zswap.max_pool_percent=20"
    "zswap.shrinker_enabled=1"
  ];
  boot.initrd.kernelModules = ["lz4"];
  boot.initrd.systemd.enable = true;

  boot.kernel.sysctl."vm.max_map_count" = 2147483642;

  networking.hostName = "toaster";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Jakarta";

  services.libinput.enable = true;
  services.zerotierone.enable = true;

  boot.supportedFilesystems = ["ntfs"];
  services.udisks2.enable = true;

  programs.zsh.enable = true;

  users.users.nori = {
    isNormalUser = true;
    extraGroups = ["wheel" "gamemode" "adbusers" "i2c" "networkmanager"];
    packages = with pkgs; [
      tree
    ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    lz4
    vim
    wget
    lshw
    inxi
    brightnessctl
    libnotify
    htop
    btop
    jq
    playerctl
    feh
    swaybg
    linux-wifi-hotspot
    haveged
    lm_sensors
    undervolt
    scrcpy
    ffmpeg-full
    ouch
    fastfetch
    helvum
    pavucontrol
    bat
    vulkan-tools
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
  ];

  programs.adb.enable = true;
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        softrealtime = "auto";
        renice = 10;
      };
      custom = {
        start = "/run/current-system/sw/bin/notify-send -a 'Gamemode' 'Optimisations activated'";
        end = "/run/current-system/sw/bin/notify-send -a 'Gamemode' 'Optimisations deactivated'";
      };
    };
  };

  services.thermald.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;
    };
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnfree = true;

  # DO NOT CHANGE
  system.stateVersion = "25.05";
}
