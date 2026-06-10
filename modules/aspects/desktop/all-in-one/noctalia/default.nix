{
  inputs,
  den,
  ...
}: {
  flake-file.inputs.noctalia.url = "github:noctalia-dev/noctalia";

  den.aspects.noctalia = {
    includes = [
      den.aspects.wallpapers
      den.aspects.theme
    ];

    nixos = {
      nixpkgs.overlays = [inputs.noctalia.overlays.default];
    };

    homeManager = {
      config,
      lib,
      ...
    }: {
      imports = [inputs.noctalia.homeModules.default];

      # noctalia writes the overrides file atomically, hence breaking
      # the symlink created by mkAspectSymlink
      #
      # we can just tell it to write in this dir instead
      systemd.user.services.noctalia = {
        Service.Environment = [
          "NOCTALIA_STATE_HOME=${config.dotfilesDirectory}/modules/aspects/desktop/all-in-one"
        ];
      };

      programs.noctalia = {
        enable = true;
        systemd.enable = true;
        customPalettes = with config.lib.stylix.colors.withHashtag; {
          stylix = let
            palette = {
              mPrimary = base0D;
              mOnPrimary = base00;
              mSecondary = base0E;
              mOnSecondary = base00;
              mTertiary = base0C;
              mOnTertiary = base00;
              mError = base08;
              mOnError = base00;
              mSurface = base00;
              mOnSurface = base05;
              mHover = base0C;
              mOnHover = base00;
              mSurfaceVariant = base01;
              mOnSurfaceVariant = base04;
              mOutline = base03;
              mShadow = base00;
              terminal = {
                foreground = base05;
                background = base00;
                selectionFg = base05;
                selectionBg = base02;
                cursor = base05;
                cursorText = base00;
                normal = {
                  black = base00;
                  white = base05;
                  inherit red green yellow blue magenta cyan;
                };
                bright = {
                  black = base03;
                  white = base07;
                  red = bright-red;
                  green = bright-green;
                  yellow = bright-yellow;
                  blue = bright-blue;
                  magenta = bright-magenta;
                  cyan = bright-cyan;
                };
              };
            };
          in {
            dark = palette;
            light = palette;
          };
        };

        # for when stylix catches up
        settings = lib.mkForce {};
      };
    };

    provides.niri = {
      includes = [
        den.aspects.wlogout
      ];

      homeManager = {config, ...}: {
        programs.niri.settings.binds = with config.lib.niri.actions; let
          nm = spawn "noctalia" "msg";
        in {
          "Mod+D" = {
            action = nm "panel-toggle" "launcher";
            hotkey-overlay.title = "Toggle Application Launcher";
          };
          "Mod+N" = {
            action = nm "panel-toggle" "control-center";
            hotkey-overlay.title = "Toggle Control Center";
          };
          "Mod+Comma" = {
            action = nm "settings-toggle";
            hotkey-overlay.title = "Toggle Settings";
          };
          "Super+Alt+L" = {
            action = nm "session lock";
            hotkey-overlay.title = "Toggle Lock Screen";
          };
          "Alt+F4" = {
            action = config.lib.niri.actions.spawn "wlogout";
            hotkey-overlay.title = "Toggle Power Menu";
          };
          "XF86AudioRaiseVolume" = {
            allow-when-locked = true;
            action = nm "volume-up" "3";
          };
          "XF86AudioLowerVolume" = {
            allow-when-locked = true;
            action = nm "volume-down" "3";
          };
          "XF86AudioMute" = {
            allow-when-locked = true;
            action = nm "volume-mute";
          };
          "XF86AudioMicMute" = {
            allow-when-locked = true;
            action = nm "mic-mute";
          };
          "XF86MonBrightnessUp" = {
            allow-when-locked = true;
            action = nm "brightness-up" "eDP-1" "5";
          };
          "XF86MonBrightnessDown" = {
            allow-when-locked = true;
            action = nm "brightness-down" "eDP-1" "5";
          };
          "Mod+Alt+N" = {
            allow-when-locked = true;
            action = nm "nightlight-toggle";
            hotkey-overlay.title = "Toggle Night Mode";
          };
        };
      };
    };
  };
}
