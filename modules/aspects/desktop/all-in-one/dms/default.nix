{
  inputs,
  den,
  ...
}: {
  flake-file.inputs = {
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  den.aspects.dms = {
    includes = [
      den.aspects.theme
      den.aspects.wallpapers
    ];

    homeManager = {
      config,
      pkgs,
      ...
    }: {
      imports = [
        inputs.dms.homeModules.dank-material-shell
        inputs.dms-plugin-registry.modules.default
      ];

      programs.dank-material-shell = {
        enable = true;

        enableSystemMonitoring = true;
        # enableCalendarEvents = true; # TODO
        enableClipboardPaste = true;

        dgop.package = inputs.dgop.packages.${pkgs.system}.default;

        settings = {
          widgetColorMode = "colorful";
          cornerRadius = 6;
          use24HourClock = true;
          blurEnabled = true;
          blurForegroundLayers = true;
          useAutoLocation = true;

          # disable matugen
          matugenTemplateGtk = false;
          matugenTemplateNiri = false;
          matugenTemplateHyprland = false;
          matugenTemplateMangowc = false;
          matugenTemplateQt5ct = false;
          matugenTemplateQt6ct = false;
          matugenTemplateFirefox = false;
          matugenTemplatePywalfox = false;
          matugenTemplateZenBrowser = false;
          matugenTemplateVesktop = false;
          matugenTemplateEquibop = false;
          matugenTemplateGhostty = false;
          matugenTemplateKitty = false;
          matugenTemplateFoot = false;
          matugenTemplateAlacritty = false;
          matugenTemplateNeovim = false;
          matugenTemplateWezterm = false;
          matugenTemplateDgop = false;
          matugenTemplateKcolorscheme = false;
          matugenTemplateVscode = false;
          matugenTemplateEmacs = false;
          matugenTemplateZed = false;

          # on ac give a 15s period
          # to cancel the lock
          acMonitorTimeout = 300;
          acLockTimeout = 315;
          acSuspendTimeout = 0;

          # on battery lock right away when
          # the monitor times out
          batteryMonitorTimeout = 180;
          batteryLockTimeout = 180;
          batterySuspendTimeout = 300;
          # i assume 0: suspend 1: hibernate 2: suspend-then-hibernate
          batterySuspendBehavior = 0;
        };

        session = {
          isLightMode = false;
          perMonitorWallpaper = true;
          monitorWallpapers = {
            HDMI-A-5 = "${config.home.homeDirectory}/Pictures/Wallpapers/liquid_abstract.jpg";
            eDP-1 = "${config.home.homeDirectory}/Pictures/Wallpapers/facade_arch_relief.jpg";
          };
          hiddenTrayIds = [
            "Fcitx"
          ];
        };

        clipboardSettings = {
          maxHistory = 25;
          autoClearDays = 1;
          clearAtStartup = true;
          disabled = false;
          disableHistory = false;
          disablePersist = true;
        };

        plugins = {
          dankBatteryAlerts.enable = true;
          dockerManager.enable = true;
          mediaPlayer = {
            enable = true;
            settings.preferredSource = "spotify";
          };
        };
      };
    };

    provides.niri = {
      includes = [den.aspects.impure];

      homeManager = {config, ...}: {
        imports = [inputs.dms.homeModules.niri];

        xdg.configFile = {
          "DankMaterialShell/plugins/NiriColumns".source =
            config.lib.my.mkAspectSymlink
            "desktop/all-in-one/dms/plugins/NiriColumns";
        };

        programs.dank-material-shell = {
          systemd.enable = false;

          plugins = {
            niriColumns = {
              enable = true;
              src = "${config.home.homeDirectory}/.config/DankMaterialShell/plugins/NiriColumns";
            };
          };

          settings.barConfigs = [
            {
              id = "default";
              name = "Main Bar";
              enabled = true;
              position = 2;
              screenPreferences = [
                "all"
              ];
              showOnLastDisplay = true;
              leftWidgets = [
                "launcherButton"
                "workspaceSwitcher"
                "focusedWindow"
              ];
              centerWidgets = [
                "niriColumns"
                "music"
                "clock"
                "weather"
              ];
              rightWidgets = [
                "systemTray"
                "clipboard"
                "dockerManager"
                "cpuUsage"
                "memUsage"
                "notificationButton"
                "battery"
                "controlCenterButton"
              ];
              spacing = 0;
              innerPadding = 4;
              bottomGap = 0;
              transparency = config.stylix.opacity.desktop;
              widgetTransparency = 1;
              squareCorners = true;
              noBackground = false;
              maximizeWidgetIcons = false;
              maximizeWidgetText = false;
              removeWidgetPadding = false;
              widgetPadding = 8;
              gothCornersEnabled = true;
              gothCornerRadiusOverride = false;
              gothCornerRadiusValue = 12;
              borderEnabled = false;
              borderColor = "surfaceText";
              borderOpacity = 1;
              borderThickness = 1;
              widgetOutlineEnabled = false;
              widgetOutlineColor = "primary";
              widgetOutlineOpacity = 1;
              widgetOutlineThickness = 1;
              fontScale = 1;
              iconScale = 1;
              autoHide = false;
              autoHideDelay = 250;
              showOnWindowsOpen = false;
              openOnOverview = false;
              visible = true;
              popupGapsAuto = true;
              popupGapsManual = 4;
              maximizeDetection = true;
              scrollEnabled = true;
              scrollXBehavior = "column";
              scrollYBehavior = "workspace";
              shadowIntensity = 0;
              shadowOpacity = 60;
              shadowColorMode = "text";
              shadowCustomColor = "#000000";
              clickThrough = false;
            }
          ];

          niri = {
            enableKeybinds = true;
            enableSpawn = true;
            includes = {
              enable = true;
              originalFileName = "hm";
              filesToInclude = [
                "alttab"
                "layout"

                # not used yet
                "wpblur"
              ];
            };
          };
        };
      };
    };
  };
}
