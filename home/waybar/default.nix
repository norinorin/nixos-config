{
  desktop,
  lib,
  ...
}: {
  home.file.".config/waybar/modules" = {
    source = ./modules;
    recursive = true;
    executable = true;
  };
  home.file.".config/waybar/presets" = {
    source = ./presets;
    recursive = true;
    executable = true;
  };
  home.file.".config/waybar/watchers" = {
    source = ./watchers;
    recursive = true;
    executable = true;
  };

  home.file.".config/waybar/config.jsonc".source = ./presets/${desktop}/config.jsonc;
  stylix.targets.waybar.addCss = false;
  programs.waybar.style = lib.mkAfter (
    ''
      * {
          font-family: "Azeret Mono", "JetBrain Mono";
          font-size: 8pt;
      }

      window#waybar {
          transition-property: background-color;
          transition-duration: 0.5s;
          background-color: alpha(@base00, 0.8);
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

      #custom-spotify-icon {
          padding-left: 4px;
          padding-right: 8px;
          margin: 6px 2px;
          margin-right: 0;
      }

      #tray {
          padding: 0 4px;
          margin: 6px 2px;
          border-radius: 6px;
      }

      /* Start nerd font hackery */
      #custom-network.connected {
          padding-right: 7px;
      }

      #custom-network.disconnected {
          padding-right: 4px;
      }

      #custom-network {
          padding-right: 7px;
      }

      #custom-cpu-icon {
          padding-right: 4px;
      }

      #custom-memory-icon {
          padding-right: 2px;
      }

      #custom-pa-output-icon {
          padding-right: 3px;
      }

      #custom-tray-icon {
          padding-right: 4px;
      }

      #battery.icon {
          padding-right: 5px;
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
      .pa-output-drawer > .module,
      .memory-drawer > .module {
          padding-left: 4px;
      }

      .cpu-drawer > .module {
          padding-left: 3px;
      }

      .tray-drawer > .module {
          padding-left: 5px;
      }

      .battery-drawer > .module {
          padding-left: 4px;
      }
    ''
    + builtins.readFile ./presets/${desktop}/style.css
  );
}
