{
  pkgs,
  lib,
  config,
  ...
}: {
  home.packages = with pkgs; [
    xwayland-satellite-unstable
  ];

  programs.niri.settings = {
    input = {
      keyboard = {
        xkb = {
          layout = "us";
          options = "compose:menu";
        };
        repeat-rate = 50;
        repeat-delay = 300;
      };

      mouse.accel-profile = "flat";
      warp-mouse-to-focus.enable = true;
    };

    outputs = {
      # iGPU disabled
      "HDMI-A-1" = {
        enable = true;
        mode = {
          width = 1920;
          height = 1080;
        };
        position = {
          x = 0;
          y = 0;
        };
        focus-at-startup = true;
      };

      # when iGPU is enabled
      # external monitor becomes HDMI-A-5
      "HDMI-A-5" = {
        enable = true;
        mode = {
          width = 1920;
          height = 1080;
        };
        position = {
          x = 0;
          y = 0;
        };
      };

      "eDP-1" = {
        enable = true;
        mode = {
          width = 1920;
          height = 1080;
        };
        position = {
          x = 1920;
          y = 0;
        };
      };
    };

    layout = let
      gap-px = 10;
      ringWidth = 2;
    in {
      gaps = gap-px;
      struts = {
        left = -gap-px + ringWidth;
        right = -gap-px + ringWidth;
        top = -gap-px + ringWidth;
        bottom = -gap-px + ringWidth;
      };

      center-focused-column = "never";
      preset-column-widths = [
        {proportion = 1. / 3.;}
        {proportion = 1. / 2.;}
        {proportion = 2. / 3.;}
      ];
      default-column-width = {proportion = 0.5;};
      focus-ring = {
        enable = true;
        width = ringWidth;
        active = {
          gradient = {
            from = lib.mkDefault "#80c8ff";
            to = lib.mkDefault "#bbddff";
            angle = 45;
          };
        };
        inactive = {
          gradient = {
            from = lib.mkDefault "#505050";
            to = lib.mkDefault "#808080";
            relative-to = "workspace-view";
          };
        };
      };
      border.enable = false;
      shadow = {
        enable = true;
        softness = 30;
        spread = 5;
        offset = {
          x = 0;
          y = 5;
        };
        color = lib.mkDefault "#0007";
      };
    };

    prefer-no-csd = true;
    screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
    animations.enable = true;

    window-rules = [
      {
        matches = [
          {
            app-id = "firefox$";
            title = "^Picture-inPicture$";
          }
        ];
        open-floating = true;
      }
      {
        matches = [
          {
            app-id = "steam";
            title = "^notificationtoasts_\\d+_desktop$";
            is-floating = true;
          }
        ];
        default-floating-position = {
          x = 10;
          y = 10;
          relative-to = "bottom-right";
        };
      }
      {
        matches = [
          {
            app-id = "Zotero";
            title = "Quick Format Citation";
          }
        ];
        open-floating = true;
      }
    ];

    cursor = {
      theme = "Bibata-Modern-Ice";
      size = 16;
    };

    binds = with config.lib.niri.actions; {
      "Mod+Shift+Slash".action = show-hotkey-overlay;
      "Mod+Shift+E".action = quit;
      "Ctrl+Alt+Delete".action = quit;
      "Mod+Shift+P".action = power-off-monitors;

      "Mod+T".action = spawn "alacritty";
      "Mod+Return".action = spawn "alacritty";
      "Mod+D".action = spawn "fuzzel";
      "Super+Alt+L".action = spawn "swaylock";
      "Mod+Shift+C".action = spawn "dunstctl" "close-all";
      "Mod+E".action = spawn "thunar";
      "Alt+F4".action = spawn "wlogout";

      "XF86AudioRaiseVolume" = {
        allow-when-locked = true;
        action = spawn "swayosd-client" "--output-volume" "raise";
      };
      "XF86AudioLowerVolume" = {
        allow-when-locked = true;
        action = spawn "swayosd-client" "--output-volume" "lower";
      };
      "XF86AudioMute" = {
        allow-when-locked = true;
        action = spawn "swayosd-client" "--output-volume" "mute-toggle";
      };
      "XF86AudioMicMute" = {
        allow-when-locked = true;
        action = spawn "swayosd-client" "--input-volume" "mute-toggle";
      };

      "XF86AudioPlay" = {
        allow-when-locked = true;
        action = spawn "swayosd-client" "--playerctl" "play-pause";
      };
      "XF86AudioPause" = {
        allow-when-locked = true;
        action = spawn "swayosd-client" "--playerctl" "play-pause";
      };
      "XF86AudioNext" = {
        allow-when-locked = true;
        action = spawn "playerctl" "-p" "playerctld" "next";
      };
      "XF86AudioPrev" = {
        allow-when-locked = true;
        action = spawn "playerctl" "-p" "playerctld" "previous";
      };

      "XF86MonBrightnessUp" = {
        allow-when-locked = true;
        action = spawn "swayosd-client" "--brightness" "+5";
      };
      "XF86MonBrightnessDown" = {
        allow-when-locked = true;
        action = spawn "swayosd-client" "--brightness" "-5";
      };

      "Mod+Q".action = close-window;

      "Mod+Left".action = focus-column-left;
      "Mod+Down".action = focus-window-or-workspace-down;
      "Mod+Up".action = focus-window-or-workspace-up;
      "Mod+Right".action = focus-column-right;
      "Mod+H".action = focus-column-left;
      "Mod+J".action = focus-window-or-workspace-down;
      "Mod+K".action = focus-window-or-workspace-up;
      "Mod+L".action = focus-column-right;

      "Mod+Ctrl+Left".action = move-column-left;
      "Mod+Ctrl+Down".action = move-window-down-or-to-workspace-down;
      "Mod+Ctrl+Up".action = move-window-up-or-to-workspace-up;
      "Mod+Ctrl+Right".action = move-column-right;
      "Mod+Ctrl+H".action = move-column-left;
      "Mod+Ctrl+J".action = move-window-down-or-to-workspace-down;
      "Mod+Ctrl+K".action = move-window-up-or-to-workspace-up;
      "Mod+Ctrl+L".action = move-column-right;

      "Mod+Home".action = focus-column-first;
      "Mod+End".action = focus-column-last;
      "Mod+Ctrl+Home".action = move-column-to-first;
      "Mod+Ctrl+End".action = move-column-to-last;

      "Mod+Shift+Left".action = focus-monitor-left;
      "Mod+Shift+Down".action = focus-monitor-down;
      "Mod+Shift+Up".action = focus-monitor-up;
      "Mod+Shift+Right".action = focus-monitor-right;
      "Mod+Shift+H".action = focus-monitor-left;
      "Mod+Shift+J".action = focus-monitor-down;
      "Mod+Shift+K".action = focus-monitor-up;
      "Mod+Shift+L".action = focus-monitor-right;

      "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
      "Mod+Shift+Ctrl+Down".action = move-column-to-monitor-down;
      "Mod+Shift+Ctrl+Up".action = move-column-to-monitor-up;
      "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;
      "Mod+Shift+Ctrl+H".action = move-column-to-monitor-left;
      "Mod+Shift+Ctrl+J".action = move-column-to-monitor-down;
      "Mod+Shift+Ctrl+K".action = move-column-to-monitor-up;
      "Mod+Shift+Ctrl+L".action = move-column-to-monitor-right;

      "Mod+Page_Down".action = focus-workspace-down;
      "Mod+Page_Up".action = focus-workspace-up;
      "Mod+U".action = focus-workspace-down;
      "Mod+I".action = focus-workspace-up;

      "Mod+Ctrl+Page_Down".action = move-column-to-workspace-down;
      "Mod+Ctrl+Page_Up".action = move-column-to-workspace-up;
      "Mod+Ctrl+U".action = move-column-to-workspace-down;
      "Mod+Ctrl+I".action = move-column-to-workspace-up;

      "Mod+Shift+Page_Down".action = move-workspace-down;
      "Mod+Shift+Page_Up".action = move-workspace-up;
      "Mod+Shift+U".action = move-workspace-down;
      "Mod+Shift+I".action = move-workspace-up;

      "Mod+WheelScrollDown" = {
        cooldown-ms = 150;
        action = focus-workspace-down;
      };
      "Mod+WheelScrollUp" = {
        cooldown-ms = 150;
        action = focus-workspace-up;
      };
      "Mod+Ctrl+WheelScrollDown" = {
        cooldown-ms = 150;
        action = move-column-to-workspace-down;
      };
      "Mod+Ctrl+WheelScrollUp" = {
        cooldown-ms = 150;
        action = move-column-to-workspace-up;
      };

      "Mod+WheelScrollRight".action = focus-column-right;
      "Mod+WheelScrollLeft".action = focus-column-left;
      "Mod+Ctrl+WheelScrollRight".action = move-column-right;
      "Mod+Ctrl+WheelScrollLeft".action = move-column-left;

      "Mod+Shift+WheelScrollDown".action = focus-column-right;
      "Mod+Shift+WheelScrollUp".action = focus-column-left;
      "Mod+Ctrl+Shift+WheelScrollDown".action = move-column-right;
      "Mod+Ctrl+Shift+WheelScrollUp".action = move-column-left;

      "Mod+1".action = focus-workspace 1;
      "Mod+2".action = focus-workspace 2;
      "Mod+3".action = focus-workspace 3;
      "Mod+4".action = focus-workspace 4;
      "Mod+5".action = focus-workspace 5;
      "Mod+6".action = focus-workspace 6;
      "Mod+7".action = focus-workspace 7;
      "Mod+8".action = focus-workspace 8;
      "Mod+9".action = focus-workspace 9;

      "Mod+Ctrl+1".action.move-column-to-workspace = 1;
      "Mod+Ctrl+2".action.move-column-to-workspace = 2;
      "Mod+Ctrl+3".action.move-column-to-workspace = 3;
      "Mod+Ctrl+4".action.move-column-to-workspace = 4;
      "Mod+Ctrl+5".action.move-column-to-workspace = 5;
      "Mod+Ctrl+6".action.move-column-to-workspace = 6;
      "Mod+Ctrl+7".action.move-column-to-workspace = 7;
      "Mod+Ctrl+8".action.move-column-to-workspace = 8;
      "Mod+Ctrl+9".action.move-column-to-workspace = 9;

      "Mod+BracketLeft".action = consume-or-expel-window-left;
      "Mod+BracketRight".action = consume-or-expel-window-right;
      "Mod+Comma".action = consume-window-into-column;
      "Mod+Period".action = expel-window-from-column;

      "Mod+R".action = switch-preset-column-width;
      "Mod+Shift+R".action = switch-preset-window-height;
      "Mod+Ctrl+R".action = reset-window-height;
      "Mod+F".action = maximize-column;
      "Mod+Shift+F".action = fullscreen-window;
      "Mod+Ctrl+F".action = expand-column-to-available-width;
      "Mod+C".action = center-column;

      "Mod+Minus".action = set-column-width "-10%";
      "Mod+Equal".action = set-column-width "+10%";

      "Mod+Shift+Minus".action = set-window-height "-10%";
      "Mod+Shift+Equal".action = set-window-height "+10%";

      "Mod+V".action = toggle-window-floating;
      "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;
      "Mod+W".action = toggle-column-tabbed-display;

      "Print".action.screenshot = [];
      "Ctrl+Print".action = spawn "sh" "-c" "grim - | wl-copy";
      "Alt+Print".action.screenshot-window = [];

      "Mod+Escape" = {
        allow-inhibiting = false;
        action = toggle-keyboard-shortcuts-inhibit;
      };
    };

    environment = {
      DISPLAY = ":0";
      QT_QPA_PLATFORM = "wayland";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      SDL_VIDEODRIVER = "wayland";
      NIXOS_OZONE_WL = "1";
    };

    gestures = {
      dnd-edge-view-scroll = {
        trigger-width = 30;
        delay-ms = 100;
        max-speed = 1500;
      };

      dnd-edge-workspace-switch = {
        trigger-height = 50;
        delay-ms = 100;
        max-speed = 1500;
      };

      hot-corners.enable = false;
    };

    xwayland-satellite = {
      enable = true;
      path = lib.getExe pkgs.xwayland-satellite-unstable;
    };

    spawn-at-startup = let
      waybarConfig = "${config.xdg.configHome}/waybar/presets/niri";
    in [
      {sh = "sleep 10 && ${pkgs.waybar}/bin/waybar -c ${waybarConfig}/config.jsonc -s ${waybarConfig}/style.css";}
      {sh = "sleep 10 && ~/.config/waybar/watchers/spotify-watcher";}
      {sh = "sleep 10 && ~/.config/waybar/watchers/niri-window-count-watcher HDMI-A-1";}
      {sh = "sleep 10 && ~/.config/waybar/watchers/niri-window-count-watcher HDMI-A-5";}
      {sh = "sleep 10 && ~/.config/waybar/watchers/niri-window-count-watcher eDP-1";}
    ];
  };
}
