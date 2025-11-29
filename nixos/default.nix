{
  config,
  lib,
  pkgs,
  inputs,
  desktop,
  ...
}: {
  _module.args.pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    inherit (config.nixpkgs) config;
  };

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
    (import ../modules {inherit pkgs lib desktop;})
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "toaster";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Jakarta";

  services.displayManager.ly.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.libinput.enable = true;
  services.zerotierone.enable = true;

  programs.zsh.enable = true;

  users.users.nori = {
    isNormalUser = true;
    extraGroups = ["wheel" "gamemode" "adbusers"];
    packages = with pkgs; [
      tree
    ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
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

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnfree = true;

  # DO NOT CHANGE
  system.stateVersion = "25.05";
}
