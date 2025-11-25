{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ./gc.nix
      ./fonts.nix
      ./nvidia.nix
      ./wayland.nix
      ./theme.nix
      ./x11.nix
      ./undervolt.nix
      ../modules
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
    pulse.enable = true;
  };

  services.libinput.enable = true;
  
  programs.zsh.enable = true;
  
  users.users.nori = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
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
  ];

  # use scrcpy to turn mobile phones into webcams
  programs.obs-studio.enableVirtualCamera = true;

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # DO NOT CHANGE
  system.stateVersion = "25.05"; 
}

