{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [./hypridle.nix];

  home.sessionVariables.NIXOS_OZONE_WL = "1";

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.variables = ["--all"];
    plugins = [inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces];
    # submaps = {
    #     move = {
    #         settings = {
    #             binde = [
    #                 ", L, moveactive,  10   0"
    #                 ", H, moveactive, -10   0"
    #                 ", K, moveactive,  0  -10"
    #                 ", J, moveactive,  0   10"
    #             ];
    #             bind = [ ", Escape, submap, reset" ];
    #         };
    #     };
    #     resize = {
    #         settings = {
    #             binde = [
    #                 ", right, resizeactive,  10  0"
    #                 ", left,  resizeactive, -10  0"
    #                 ", up,    resizeactive,  0 -10"
    #                 ", down,  resizeactive,  0  10"
    #                 ", L,     resizeactive,  10  0"
    #                 ", H,     resizeactive, -10  0"
    #                 ", K,     resizeactive,  0 -10"
    #                 ", J,     resizeactive,  0  10"
    #             ];
    #             bind = [ ", Escape, submap, reset" ];
    #         };
    #     };
    # };
    settings = {
      "$mod" = "SUPER";
      "$terminal" = "alacritty";
      "$fileManager" = "thunar";
      "$menu" = "fuzzel";
      monitor = [
        "HDMI-A-1,1920x1080@180,0x0,1"
        "eDP-1,1920x1080@144,auto-right,1"
      ];
      general = {
        gaps_in = 2;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = lib.mkDefault "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = lib.mkDefault "rgba(595959aa)";
        resize_on_border = false;
        allow_tearing = true;
        layout = "dwindle";
      };
      decoration = {
        active_opacity = 0.95;
        inactive_opacity = 0.95;
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
        };
        blur = {
          enabled = true;
          size = 7;
          passes = 1;
          vibrancy = 0.1696;
          new_optimizations = true;
        };
      };
      animations = {
        enabled = "yes, please :)";
        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];
        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, slide"
          "workspacesIn, 1, 1.21, almostLinear, slide"
          "workspacesOut, 1, 1.94, almostLinear, slide"
        ];
      };
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      master = {
        new_status = "master";
      };
      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };
      input = {
        kb_layout = "us";
        kb_options = "compose:menu";
        follow_mouse = 2;
        sensitivity = 0;
        accel_profile = "flat";
        repeat_rate = 50;
        repeat_delay = 300;
        touchpad = {
          natural_scroll = false;
        };
      };
      gestures = {
        workspace_swipe_touch = true;
      };
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
      bindel = [
        ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume +5"
        ", XF86AudioLowerVolume, exec, swayosd-client --output-volume -5"
        ", XF86AudioMute,        exec, swayosd-client --output-volume mute-toggle"
        ", XF86AudioPlay,        exec, swayosd-client --playerctl play-pause"
        ", XF86AudioPause,       exec, swayosd-client --playerctl play-pause"
        ", XF86MonbrightnessUp,  exec, swayosd-client --brightness +5"
        ", XF86MonbrightnessDown,exec, swayosd-client --brightness -5"
        ", XF86AudioNext,        exec, playerctl -p playerctld next"
        ", XF86AudioPrev,        exec, playerctl -p playerctld previous"
      ];
      bind =
        [
          "$mod SHIFT, return, exec, $terminal"
          "$mod      , Q, killactive"
          "$mod SHIFT, E, exit"
          "$mod      , E, exec, $fileManager"
          "$mod      , V, togglefloating"
          "$mod      , D, exec, $menu"
          "$mod      , P, togglesplit"
          "$mod      , F, fullscreen"

          "$mod      , H, movefocus, l"
          "$mod      , L, movefocus, r"
          "$mod      , K, movefocus, u"
          "$mod      , J, movefocus, d"

          "$mod SHIFT, H, movewindow, l"
          "$mod SHIFT, L, movewindow, r"
          "$mod SHIFT, K, movewindow, u"
          "$mod SHIFT, J, movewindow, d"

          "$mod      , Z, submap, move"
          "$mod      , A, submap, resize"

          "$mod      , Period, focusmonitor, +1"
          "$mod      , Comma, focusmonitor, -1"
          "$mod SHIFT, Period, split-changemonitor, next"
          "$mod SHIFT, Comma, split-changemonitor, prev"

          "$mod      , S, togglespecialworkspace, magic"
          "$mod SHIFT, S, movetoworkspace, special:magic"
          "$mod      , mouse_down, workspace, e+1"
          "$mod      , mouse_up, workspace, e-1"

          "$mod      , C, exec, dunstctl close-all"
          "          , Print, exec, grimblast copy area"

          # floating windows
          "ALT       , Tab, cyclenext"
          "ALT       , Tab, bringactivetotop"
          "ALT SHIFT , Tab, cyclenext, prev"
          "ALT SHIFT , Tab, bringactivetotop"

          "ALT       , F1, exec, ~/.config/hypr/gamemode.sh"

          # OBS
          "CTRL ALT  , apostrophe, pass, class:com.obsproject.Studio"
          "CTRL ALT  , semicolon, pass, class:com.obsproject.Studio"
          "CTRL      , backslash, pass, class:com.obsproject.Studio"

          "$mod ALT  , L, exec, swaylock"
          "ALT       , F4, exec, wlogout"
        ]
        ++ (
          let
            mod = a: b: a - b * (builtins.div a b);
            shown = builtins.genList (i: mod (i + 1) 10) 10;
            mapped = map (i:
              if i == 0
              then 10
              else i)
            shown;
          in
            builtins.concatLists (builtins.genList (
                i: let
                  s = builtins.elemAt shown i;
                  m = builtins.elemAt mapped i;
                in [
                  "$mod, code:1${toString i}, split-workspace, ${toString s}"
                  "$mod SHIFT, code:1${toString i}, split-movetoworkspace, ${toString m}"
                ]
              )
              10)
        );
      plugin = {
        split-monitor-workspaces = {
          count = 10;
          keep_focused = 1;
          enable_notifications = 0;
          enable_persistent_workspaces = 1;
        };
      };
      cursor = {
        no_hardware_cursors = 1;
      };
      layerrule = [
        "animation slide, match:namespace notifications"
        "blur on, match:namespace waybar"
        "dim_around on, blur on, match:namespace launcher"
      ];
      windowrule = [
        # gaming
        "match:class ^(gamescope)$, immediate on"
        "match:initial_title ^(Minecraft\* [\d+\.]+)$, immediate on"
        "match:class ^osu!$, immediate on"

        "match:class .*, idle_inhibit fullscreen"

        # zotero
        "match:class ^(Zotero)$, match:title ^(Quick Format Citation|Progress)$, float on"
        "match:class ^(Zotero)$, match:title ^(Progress)$, max_size 400 50"

        # floating windows
        "float on, match:class mpv"
        "float on, match:class org.pulseaudio.pavucontrol"
        "float on, match:class steam, match:title negative:^(Steam)$"
        "float on, match:class org.qbittorrent.qBittorrent, match:title negative:^(qBittorrent)\s+v(\d+\.?)+$"

        # experimental
        "float on, match:class xdg-desktop-portal.*"
        "size 800 600, match:class xdg-desktop-portal.*"

        "suppress_event maximize, match:class .*"
        "size 1024 576, match:class mpv"

        # non-transparent windows
        "opacity 1.0, match:class mpv"
      ];
      exec = [
        "~/Wallpapers/wally"
      ];
      exec-once = [
        "sleep 10 && ~/.config/waybar/watchers/spotify-watcher"
        "sleep 10 && ~/.config/waybar/watchers/kanata-watcher"
      ];
    };
    # use this until the next hm release cycle
    extraConfig = ''
      submap = move
          binde = , L, moveactive,  10  0
          binde = , H, moveactive, -10  0
          binde = , K, moveactive,  0 -10
          binde = , J, moveactive,  0  10
          bind = , Escape, submap, reset
      submap = reset

      submap = resize
          binde = , right, resizeactive,  10  0
          binde = , left,  resizeactive, -10  0
          binde = , up,    resizeactive,  0 -10
          binde = , down,  resizeactive,  0  10
          binde = , L,     resizeactive,  10  0
          binde = , H,     resizeactive, -10  0
          binde = , K,     resizeactive,  0 -10
          binde = , J,     resizeactive,  0  10
          bind = , Escape, submap, reset
      submap = reset
    '';
  };

  home.file.".config/hypr/gamemode.sh" = {
    text = ''
      #!/usr/bin/env sh
      HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')
      if [ "$HYPRGAMEMODE" = 1 ] ; then
          hyprctl --batch "\
              keyword animations:enabled 0;\
              keyword decoration:shadow:enabled 0;\
              keyword decoration:blur:enabled 0;\
              keyword general:gaps_in 0;\
              keyword general:gaps_out 0;\
              keyword general:border_size 1;\
              keyword decoration:rounding 0"
          exit
      fi
      hyprctl reload
    '';
    executable = true;
  };

  home.packages = with pkgs; [
    grimblast
  ];

  xdg.configFile."uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
}
