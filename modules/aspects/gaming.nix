{inputs, ...}: {
  flake-file.inputs.nix-gaming.url = "github:fufexan/nix-gaming";

  den.aspects.gaming = {
    nixos = {pkgs, ...}: {
      imports = [inputs.nix-gaming.nixosModules.pipewireLowLatency];

      nix.settings = {
        substituters = ["https://nix-gaming.cachix.org"];
        trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
      };

      programs = {
        steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
          localNetworkGameTransfers.openFirewall = true;
          extraCompatPackages = [pkgs.proton-ge-bin];
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
              start = "${pkgs.libnotify}/bin/notify-send -a 'Gamemode' 'Optimisations activated'";
              end = "${pkgs.libnotify}/bin/notify-send -a 'Gamemode' 'Optimisations deactivated'";
            };
          };
        };
      };

      services = {
        pipewire.lowLatency = {
          enable = true;
          quantum = 128;
        };
      };

      environment.systemPackages = with pkgs; [
        (prismlauncher.override {
          additionalLibs = [libvlc];
          additionalPrograms = [ffmpeg];
          jdks = [graalvmPackages.graalvm-ce graalvmPackages.graalvm-oracle_17 javaPackages.compiler.temurin-bin.jre-21];
        })
      ];
    };

    nixosOtg = {lib, ...}: {
      services.pipewire = {
        lowLatency.enable = lib.mkForce false;
      };
    };

    homeManager = {pkgs, ...}: let
      gamePkgs = inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system};
    in {
      home.packages = with pkgs; [
        (osu-lazer-bin.override
          {
            nativeWayland = true;
          })
        (heroic.override {
          extraPkgs = pkgs: [
            pkgs.gamescope
            pkgs.gamemode
          ];
        })
        gamePkgs.osu-stable
        parsec-bin
      ];
    };

    users.extraGroups = ["gamemode"];
  };
}
