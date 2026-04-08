{
  config,
  pkgs,
  inputs,
  lib,
  displayManager,
  username,
  specialArgs,
  ...
}: let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    inherit (config.nixpkgs) config;
  };
in {
  _module.args.pkgs-unstable = pkgs-unstable;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = import ../users/${username}.nix;
    backupFileExtension = "backup";
    extraSpecialArgs = specialArgs // {inherit pkgs-unstable;};
  };

  imports = [
    ./hardware-configuration.nix
    ./gc.nix
    ./fonts.nix
    ./nvidia.nix
    ./wayland.nix
    ./theme.nix
    ./x11.nix
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
    ./sops.nix

    (import ../modules {inherit config lib pkgs inputs displayManager;})
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs-unstable.linuxPackages_zen;
  boot.kernelParams = [
    "zswap.enabled=1"
    "zswap.compressor=lz4"
    "zswap.max_pool_percent=20"
    "zswap.shrinker_enabled=1"
  ];
  boot.initrd.kernelModules = ["lz4"];
  boot.initrd.systemd.enable = true;

  boot.kernel.sysctl."vm.max_map_count" = 2147483642;

  networking = {
    hostName = "toaster";
    networkmanager = {
      enable = true;
      dns = "none";
      # prevent nm from resetting enp7s0 during dhcp renewals.
      # this allows 'create_ap -m bridge' to maintain the bridge enslavement
      # without the interface flapping at the top of the hour.
      unmanaged = ["enp7s0"];
    };
    useDHCP = false;
    dhcpcd.enable = false;
    nameservers = [
      "127.0.0.1"
      "::1"
    ];
  };

  time.timeZone = "Asia/Jakarta";

  boot.supportedFilesystems = ["ntfs"];

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
    upower
    gamescope
  ];

  programs = {
    zsh.enable = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    gamemode = {
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
    kdeconnect.enable = true;
  };

  services = {
    libinput.enable = true;
    zerotierone = {
      enable = true;
      joinNetworks = [
        "2873fd00f2dc345a"
        "166359304ea191b2"
      ];
    };
    udisks2.enable = true;
    thermald.enable = true;
    tlp = {
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
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = true;
        Macs = [
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256-etm@openssh.com"
          "umac-128-etm@openssh.com"

          # Samsung MyFiles
          "hmac-sha1"
          "hmac-sha2-256"
          "hmac-md5"
        ];
      };
      extraConfig = ''
        # Samsung MyFiles
        HostKeyAlgorithms +ssh-rsa
        PubkeyAcceptedAlgorithms +ssh-rsa
      '';
    };
    ratbagd.enable = true;
    upower.enable = true;
    postgresql = {
      enable = true;
      ensureDatabases = ["maimai-tracker"];
      authentication = pkgs.lib.mkOverride 10 ''
        #type database  DBuser  auth-method
        local all       all     trust
      '';
    };
    dnscrypt-proxy = {
      enable = true;
      settings = {
        ipv6_servers = true;
        require_dnssec = true;
        sources.public-resolvers = {
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
            "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
          ];
          cache_file = "/var/cache/dnscrypt-proxy/public-resolvers.md";
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        };
        server_names = ["cloudflare"];
      };
    };
  };

  specialisation.on-the-go.configuration = {
    system.nixos.tags = ["on-the-go"];
    services = {
      openssh.enable = lib.mkForce false;
      zerotierone.enable = lib.mkForce false;
      postgresql.enable = lib.mkForce false;
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      {
        from = 8000;
        to = 9000;
      }
    ];

    # Palworld
    allowedTCPPorts = [25575];
    allowedUDPPorts = [8211];
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnfree = true;

  # DO NOT CHANGE
  system.stateVersion = "25.05";
}
