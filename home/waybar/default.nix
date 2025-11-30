{
  config,
  lib,
  ...
}: {
  xdg.configFile."waybar/modules" = {
    source = ./modules;
    recursive = true;
    executable = true;
  };

  xdg.configFile."waybar/presets" = {
    source = ./presets;
    recursive = true;
    executable = true;
  };

  xdg.configFile."waybar/watchers" = {
    source = ./watchers;
    recursive = true;
    executable = true;
  };

  xdg.configFile."waybar/sharedModules.jsonc".text = let
    I2C-bus = "5";
    batteryDevice = "BAT1";
  in ''
    {
        "modules-center": [
            "custom/padding-xl",
            "clock",
            "custom/padding-xl"
        ],
        "modules-right": [
            "custom/spotify-icon",
            "custom/spotify",
            "custom/padding",
            "image#openweather-icon",
            "custom/openweather-text",
            "custom/openweather-poller",
            "custom/separator",
            "custom/pa-output-icon",
            "group/pa-output",
            "custom/padding",
            "custom/brightness-icon",
            "custom/brightness",
            "custom/padding",
            "custom/cpu-icon",
            "cpu",
            "custom/padding",
            "custom/memory-icon",
            "memory",
            "custom/padding",
            "battery#icon",
            "battery#text",
            "custom/padding",
            "custom/network",
            "custom/padding",
            "group/hidden-tray",
            "custom/padding"
        ],
        "custom/brightness-icon": {
            "format": "",
            "tooltip": false,
            "on-scroll-up": "ddcutil -b ${I2C-bus} setvcp 10 + 10",
            "on-scroll-down": "ddcutil -b ${I2C-bus} setvcp 10 - 10"
        },
        // https://github.com/Alexays/Waybar/issues/981#issuecomment-1824648293
        "custom/brightness": {
            "exec": "ddcutil -b ${I2C-bus} getvcp 10 -t | perl -nE 'if (/ C (\\d+) /) { say $1; }'",
            "exec-if": "sleep 0.1",
            "format": "{}%",
            "format-icons": [
                ""
            ],
            "interval": "once",
            "on-scroll-up": "ddcutil -b ${I2C-bus} setvcp 10 + 10",
            "on-scroll-down": "ddcutil -b ${I2C-bus} setvcp 10 - 10"
        },
        "group/hidden-tray": {
            "orientation": "inherit",
            "drawer": {
                "transition-duration": 500,
                "children-class": "tray-drawer",
                "click-to-reveal": true
            },
            "modules": [
                "custom/tray-icon",
                "tray"
            ]
        },
        "custom/tray-icon": {
            "format": "󰀻",
            "tooltip": false
        },
        "tray": {
            "icon-size": 12,
            "spacing": 4
        },
        "clock": {
            "format": "{:%a, %d %b %H:%M}",
            "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
            "on-click": "$TERMINAL -e calcurse"
        },
        "custom/cpu-icon": {
            "format": "",
            "tooltip": false
        },
        "cpu": {
            "format": "{usage}%",
            "tooltip": false
        },
        "custom/memory-icon": {
            "format": "",
            "tooltip": false
        },
        "memory": {
            "format": "{}%"
        },
        "custom/pa-output-icon": {
            "format": "",
            "tooltip": false,
            "on-scroll-up": "swayosd-client --output-volume +1",
            "on-scroll-down": "swayosd-client --output-volume -1",
            "on-click": "pavucontrol",
        },
        "pulseaudio#output": {
            "format": "{volume}%",
            "on-click": null,
            "on-scroll-up": "swayosd-client --output-volume +1",
            "on-scroll-down": "swayosd-client --output-volume -1",
        },
        "pulseaudio/slider#output": {
            "min": 0,
            "max": 100,
            "orientation": "horizontal",
            "on-scroll-up": "swayosd-client --output-volume +1", // doesn't actually work
            "on-scroll-down": "swayosd-client --output-volume -1",
        },
        "battery#icon": {
            "bat": "${batteryDevice}",
            "interval": 60,
            "states": {
                "warning": 30,
                "critical": 15
            },
            "format": "{icon}",
            "format-icons": [
                "",
                "",
                "",
                "",
                ""
            ],
            "max-length": 25,
            "tooltip-format": "{timeTo} ({capacity}%, {cycles} cycles)"
        },
        "battery#text": {
            "bat": "${batteryDevice}",
            "interval": 60,
            "states": {
                "warning": 30,
                "critical": 15
            },
            "format": "{capacity}%",
            "max-length": 25,
            "tooltip-format": "{timeTo} ({capacity}%, {cycles} cycles)"
        },
        "group/pa-output": {
            "orientation": "inherit",
            "drawer": {
                "transition-duration": 500,
                "children-class": "pa-output-drawer",
                "click-to-reveal": true
            },
            "modules": [
                "pulseaudio#output",
                "pulseaudio/slider#output"
            ]
        },
        "custom/spotify-icon": {
            "format": "{icon}",
            "exec": "cat /tmp/sb-spotify 2>/dev/null",
            "interval": "once",
            "format-icons": "",
            "signal": 18 // custom/spotify-poller sends signal 18 every time it updates /tmp/sb-spotify
        },
        "custom/spotify": {
            "format": "{}",
            "exec": "cat /tmp/sb-spotify 2>/dev/null",
            "interval": "once",
            "signal": 18 // custom/spotify-poller sends signal 18 every time it updates /tmp/sb-spotify
        },
        "custom/network": {
            "format": "{}",
            "exec": "$HOME/.config/waybar/modules/network",
            "interval": 60,
            "tooltip": false,
            "return-type": "json"
        },
        "custom/separator": {
            "format": " │ "
        },
        "image#openweather-icon": {
            "path": "/tmp/sb-openweather-icon",
            "signal": 12
        },
        "custom/openweather-text": {
            "exec": "cat /tmp/sb-openweather-text 2>/dev/null",
            "signal": 12
        },
        "custom/openweather-poller": {
            "exec": "$HOME/.config/waybar/modules/openweather",
            "interval": 1800
        },
        "custom/kanata": {
            "format": "{} <span foreground=\"#9399b2cc\">│</span>",
            "exec": "cat /tmp/sb-kanata 2>/dev/null",
            "interval": "once",
            "signal": 17
        },
        "custom/padding": {
            "format": " "
        },
        "custom/padding-xl": {
            "format": " "
        }
    }
  '';

  stylix.targets.waybar.addCss = false;
  programs.waybar.style = lib.mkAfter ''
    * {
        font-family: "Azeret Mono", "JetBrain Mono";
        font-size: 8pt;
    }

    window#waybar {
        transition-property: background-color;
        transition-duration: 0.5s;
    }

    window#waybar.hidden {
        opacity: 0.2;
    }

    button {
        border: none;
    }

    /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
    button:hover {
        background: inherit;
        box-shadow: none;
        text-shadow: none;
        transition: none;
        border: none;
    }

    #workspaces button {
        min-width: 12px;
        padding: 0 4px;
        margin: 2px 0;
        background-color: transparent;
        border-radius: 30px;
        transition:
            background-color 0.5s,
            color 0.5s,
            border-radius 0.5s;
    }

    #workspaces button.active:hover,
    #workspaces button:hover {
        box-shadow: inherit;
        text-shadow: inherit;
        transition:
            background-color 0.5s,
            color 0.5s,
            border-radius 0.5s;
    }

    #workspaces button.urgent {
        background-color: transparent;
        animation-name: urgent-blink;
        animation-duration: 0.5s;
        animation-iteration-count: infinite;
        animation-direction: alternate;
        animation-timing-function: steps(12);
    }

    #tray {
        padding: 0 4px;
        margin: 6px 2px;
        border-radius: 6px;
    }

    /* Start nerd font hackery */
    #custom-spotify-icon {
        padding-right: 6px;
    }

    #custom-network.connected {
        padding-right: 7px;
    }

    #custom-network.disconnected {
        padding-right: 4px;
    }

    #custom-cpu-icon {
        padding-right: 4px;
    }

    #custom-memory-icon {
        padding-right: 3px;
    }

    #custom-pa-output-icon {
        padding-right: 4px;
    }

    #custom-tray-icon {
        padding-right: 2px;
    }

    #battery.icon {
        padding-right: 5px;
    }

    #custom-brightness-icon {
        padding-right: 4px;
    }
    /* End nerd font hackery */

    #battery.icon.critical, #battery.text.critical {
        color: @base08;
    }

    #battery.icon.warning, #battery.text.warning {
        color: @base09;
    }

    @keyframes urgent-blink {
        to {
            color: @base0C;
        }
    }

    /* Volume slider */
    #pulseaudio-slider {
        padding: 0;
        padding-left: 5px;
    }

    #pulseaudio-slider slider {
        min-height: 0;
        min-width: 0;
        opacity: 0;
        background-image: none;
        border: none;
        box-shadow: none;
    }

    #pulseaudio-slider trough {
        min-height: 10px;
        min-width: 80px;
        border-radius: 5px;
        border: none;
    }

    #pulseaudio-slider highlight {
        min-width: 10px;
        border-radius: 5px;
        border: none;
    }

    #custom-separator {
        color: alpha(@base07, 0.8);
        padding: 0 4px;
    }

    #custom-padding-xl {
        padding: 0 10px;
    }

    /* Drawer padding */
    .pa-output-drawer>.module {
        padding-left: 4px;
    }

    #pulseaudio.output,
    #custom-brightness,
    #cpu,
    #memory,
    #battery.text {
        padding-left: 2px;
    }
  '';
}
