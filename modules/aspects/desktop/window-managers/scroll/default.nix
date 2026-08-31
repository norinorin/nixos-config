{
  den,
  inputs,
  ...
}: {
  flake-file.inputs = {
    scroll.url = "github:Diax170/scroll-flake";
  };

  den.aspects.scroll = let
    getScrollPkg = pkgs: inputs.scroll.packages.${pkgs.stdenv.hostPlatform.system}.scroll-git;
  in {
    includes = [
      den.aspects.theme
      den.aspects.alacritty
      den.aspects.thunar
      den.aspects.tools
      den.aspects.wayland-tools
    ];

    nixos = {pkgs, ...}: {
      imports = [inputs.scroll.nixosModules.default];

      programs.scroll = {
        enable = true;
        package = getScrollPkg pkgs;
        extraSessionCommands = ''
          # tell QT, GDK and others to use the Wayland backend by default, X11 if not available
          export QT_QPA_PLATFORM="wayland;xcb"
          export GDK_BACKEND="wayland,x11"
          export SDL_VIDEODRIVER=wayland
          export CLUTTER_BACKEND=wayland

          # XDG desktop variables to set scroll as the desktop
          export XDG_CURRENT_DESKTOP=scroll
          export XDG_SESSION_TYPE=wayland
          export XDG_SESSION_DESKTOP=scroll

          # configure Electron to use Wayland instead of X11
          export ELECTRON_OZONE_PLATFORM_HINT=wayland

          # on hybrid graphics, prefer Intel as the primary DRM device.
          # in single-GPU modes, leave WLR_DRM_DEVICES unset and let wlroots
          # automatically select the only available GPU.
          intel_drm="/dev/dri/by-path/pci-0000:00:02.0-card"
          nvidia_drm="/dev/dri/by-path/pci-0000:01:00.0-card"

          if [ -e "$intel_drm" ] && [ -e "$nvidia_drm" ]; then
            export WLR_DRM_DEVICES="$intel_drm:$nvidia_drm"
          else
            unset WLR_DRM_DEVICES
          fi
        '';
        extraOptions = ["--unsupported-gpu"];
        extraPackages = [];
      };

      xdg.portal = {
        enable = true;
        extraPortals = [pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr];
        wlr = {
          enable = true;
          settings.screencast = {
            chooser_type = "simple";
            chooser_cmd = "${pkgs.slurp}/bin/slurp -f 'Monitor: %o' -or";
          };
        };
      };
    };

    homeManager = {
      pkgs,
      config,
      lib,
      ...
    }: let
      scrollPkg = getScrollPkg pkgs;
      scrollnag = lib.getExe' scrollPkg "scrollnag";
      scrollmsg = lib.getExe' scrollPkg "scrollmsg";
    in {
      imports = [inputs.scroll.homeModules.default];

      xdg.configFile."scroll/config.d/overrides.conf".source =
        config.lib.my.mkAspectSymlink "desktop/window-managers/scroll/overrides.conf";

      # readd this since package == null disables this
      xdg.configFile."scroll/config".onChange = ''
        scrollSocket="''${XDG_RUNTIME_DIR:-/run/user/$UID}/scroll-ipc.$UID.$(${pkgs.procps}/bin/pgrep --uid $UID -x scroll || true).sock"
        if [ -S "$scrollSocket" ]; then
          ${scrollmsg} -s $scrollSocket reload
        fi
      '';

      xdg.configFile."scroll/scripts/goto-workspace.lua".text = ''
        local scroll = require("scroll")
        local args = ...
        local n = args[1]

        local output = scroll.workspace_get_output(scroll.focused_workspace())
        local output_name = scroll.output_get_name(output)

        scroll.command(nil, "workspace " .. n .. ":" .. output_name)
      '';

      xdg.configFile."scroll/scripts/move-to-workspace.lua".text = ''
        local scroll = require("scroll")
        local args = ...
        local n = args[1]

        local output = scroll.workspace_get_output(scroll.focused_workspace())
        local output_name = scroll.output_get_name(output)
        local target = n .. ":" .. output_name

        scroll.command(nil, "move container to workspace " .. target .. "; workspace " .. target)
      '';

      xdg.configFile."scroll/scripts/swap-workspace.lua".text = ''
        local scroll = require("scroll")
        local args = ...
        local n = args[1]

        local output = scroll.workspace_get_output(scroll.focused_workspace())
        local output_name = scroll.output_get_name(output)

        scroll.command(nil, "workspace swap " .. n .. ":" .. output_name)
      '';

      xdg.configFile."scroll/scripts/workspace-namer.lua".text = ''
        local scroll = require("scroll")

        local function used_numbers(output, exclude_ws)
          local used = {}
          for _, ws in ipairs(scroll.output_get_workspaces(output)) do
            if ws ~= exclude_ws then
              local name = scroll.workspace_get_name(ws)
              local num = tonumber(string.match(name, "^(%d+):"))
              if num then used[num] = true end
            end
          end
          return used
        end

        local function lowest_free_slot(output, exclude_ws, preferred)
          local used = used_numbers(output, exclude_ws)
          if not used[preferred] then return preferred end
          for n = 1, 10 do
            if not used[n] then return n end
          end
          -- no free slot 1-10 on this output; keep preferred, collision is unavoidable
          return preferred
        end

        local function slot_name(ws)
          local current = scroll.workspace_get_name(ws)
          local preferred = tonumber(string.match(current, "^(%d+):")) or 1
          local output = scroll.workspace_get_output(ws)
          if not output then return current end
          local slot = lowest_free_slot(output, ws, preferred)
          return slot .. ":" .. scroll.output_get_name(output)
        end

        for _, output in ipairs(scroll.root_get_outputs()) do
          for _, ws in ipairs(scroll.output_get_workspaces(output)) do
            local wanted = slot_name(ws)
            local current = scroll.workspace_get_name(ws)
            if wanted ~= current then
              scroll.command(nil, "rename workspace " .. current .. " to " .. wanted)
            end
          end
        end

        local function on_ipc_workspace(old_ws, new_ws, change, _)
          scroll.log("ipc_workspace change=" .. tostring(change))
          local ws = new_ws or old_ws
          if not ws then return end
          local wanted = slot_name(ws)
          local current = scroll.workspace_get_name(ws)
          if wanted ~= current then
            scroll.command(nil, "rename workspace " .. current .. " to " .. wanted)
          end
        end

        scroll.add_callback("ipc_workspace", on_ipc_workspace, nil)
      '';

      wayland.windowManager.scroll = let
        scriptsDir = "${config.xdg.configHome}/scroll/scripts";
      in {
        enable = true;
        package = null;
        extraConfig = ''
          include ${config.xdg.configHome}/scroll/config.d/overrides.conf
          include /etc/scroll/config.d/*

          lua ${scriptsDir}/workspace-namer.lua

          bindgesture swipe:4:right workspace next
          bindgesture swipe:4:left workspace prev
          bindgesture swipe:4:up scale_workspace overview

          layout_default_width 0.5
          layout_default_height 1.0
          layout_widths [0.33333333 0.5 0.666666667 1.0]
          layout_heights [0.33333333 0.5 0.666666667 1.0]
        '';

        config = let
          mod = config.wayland.windowManager.scroll.config.modifier;
          # provided by aspects.alacritty & aspects.thunar
          terminal = config.wayland.windowManager.scroll.config.terminal;
          filemanager = "thunar";

          # always support both the arrow keys and hjkl for directional actions
          # for one hand convenience
          dirs = {
            left = ["Left" "h"];
            down = ["Down" "j"];
            up = ["Up" "k"];
            right = ["Right" "l"];
          };
          dirKeys = dirs.left ++ dirs.down ++ dirs.up ++ dirs.right;
          dirBindings = {
            prefix ? "",
            left,
            down,
            up,
            right,
          }:
            builtins.listToAttrs (
              map (key: {
                name = "${prefix}${key}";
                value =
                  if builtins.elem key dirs.left
                  then left
                  else if builtins.elem key dirs.down
                  then down
                  else if builtins.elem key dirs.up
                  then up
                  else right;
              })
              dirKeys
            );
          numBindings = {
            prefix ? "",
            action,
          }:
            builtins.listToAttrs (
              map (n: {
                name = "${prefix}${
                  if n == 10
                  then "0"
                  else toString n
                }";
                value = action n;
              }) (builtins.genList (i: i + 1) 10)
            );
        in {
          modifier = "Mod4";
          terminal = "alacritty";

          bars = [
            {
              mode = "dock";
              hiddenState = "hide";
              position = "bottom";
              workspaceButtons = true;
              workspaceNumbers = true;
              statusCommand = "${pkgs.i3status}/bin/i3status";
              fonts = {
                names = ["monospace"];
                size = 8.0;
              };
              trayOutput = "primary";
              colors = with config.lib.stylix.colors.withHashtag; {
                background = base00;
                statusline = base04;
                separator = base02;

                focusedWorkspace = {
                  border = base0D;
                  background = base0D;
                  text = base00;
                };

                activeWorkspace = {
                  border = base03;
                  background = base02;
                  text = base06;
                };

                inactiveWorkspace = {
                  border = base02;
                  background = base00;
                  text = base04;
                };

                urgentWorkspace = {
                  border = base00;
                  background = base08;
                  text = base00;
                };

                bindingMode = {
                  border = base00;
                  background = base0E;
                  text = base00;
                };
              };
            }
          ];

          window = {
            commands = [
              {
                criteria.app_id = "^org.pulseaudio.pavucontrol$";
                command = "floating enable; resize set 70 ppt 70 ppt";
              }
              {
                # enforce pixel border for native Wayland windows
                # see https://github.com/dawsers/scroll/issues/348
                criteria.shell = "^(?!.*xwayland).*";
                command = "border pixel";
              }
            ];
          };

          focus.followMouse = "no";

          gaps = {
            inner = 4;
            outer = 16;
          };

          colors = with config.lib.stylix.colors.withHashtag; {
            focused = {
              border = base0D;
              background = base01;
              text = base05;
              indicator = base0D;
              childBorder = base0D;
            };

            focusedInactive = {
              border = base03;
              background = base01;
              text = base05;
              indicator = base0D;
              childBorder = base03;
            };

            unfocused = {
              border = base03;
              background = base00;
              text = base05;
              indicator = base0D;
              childBorder = base03;
            };
          };

          animations = rec {
            enable = true;
            style = "scale";

            default = {
              enable = true;
              duration = 220;
              var = {
                order = "simple";
                controlPoints = [0.8 0 0.25 1];
              };
            };

            workspaceSwitch = {
              enable = true;
              duration = 280;
              var = {
                order = "simple";
                controlPoints = [0.78 0 0.2 1];
              };
            };

            windowMove = {
              enable = true;
              duration = 200;
              var = {
                order = "simple";
                controlPoints = [0.22 1 0.36 1];
              };
            };

            windowMoveFloat = windowMove;

            jump = {
              enable = true;
              duration = 250;
              var = {
                order = "simple";
                controlPoints = [0.34 1.56 0.64 1];
              };
            };

            overview = {
              enable = true;
              duration = 350;
              var = {
                order = "simple";
                controlPoints = [0.78 0 0.2 1];
              };
            };

            windowOpen = {
              enable = true;
              duration = 220;
              inherit (default) var;
            };

            windowSize = {
              enable = true;
              duration = 250;
              var = {
                order = 4;
                controlPoints = [
                  0.75
                  0
                  0.9
                  1.02
                  0.5
                  0.8
                ];
              };
            };

            windowFullscreen = windowSize;

            fadeIn = {
              enable = true;
              duration = 380;
              var = {
                order = "simple";
                controlPoints = [0.4 0 0.2 1];
              };
            };

            layerShell = {
              enable = true;
              duration = 280;
              var = {
                order = "simple";
                controlPoints = [0.16 1 0.3 1];
              };
            };
          };

          input = {
            "type:pointer".accel_profile = "flat";

            "type:keyboard" = {
              repeat_delay = 300;
              repeat_rate = 50;
              xkb_layout = "us";
              xkb_options = "compose:menu";
            };
          };

          keybindings = let
            workspaceBindings = numBindings {
              prefix = "${mod}+";
              action = n: "lua ${scriptsDir}/goto-workspace.lua ${toString n}";
            };
            moveWorkspaceBindings = numBindings {
              prefix = "${mod}+Shift+";
              action = n: "lua ${scriptsDir}/move-to-workspace.lua ${toString n}";
            };
            swapWorkspaceBindings = numBindings {
              prefix = "${mod}+Ctrl+";
              action = n: "lua ${scriptsDir}/swap-workspace.lua ${toString n}";
            };

            directional = dirBindings {
              prefix = "${mod}+";
              left = "focus left";
              down = "focus down";
              up = "focus up";
              right = "focus right";
            };
            moveDirectional = dirBindings {
              prefix = "${mod}+Ctrl+";
              left = "move left";
              down = "move down";
              up = "move up";
              right = "move right";
            };
            moveDirectionalNomode = dirBindings {
              prefix = "${mod}+Alt+";
              left = "move left nomode";
              down = "move down nomode";
              up = "move up nomode";
              right = "move right nomode";
            };
            focusOutputs = dirBindings {
              prefix = "${mod}+Shift+";
              left = "focus output left";
              down = "focus output down";
              up = "focus output up";
              right = "focus output right";
            };

            moveWorkspaceOutputs = builtins.listToAttrs (
              map (key: {
                name = "${mod}+Ctrl+Shift+${key}";
                value =
                  if builtins.elem key dirs.left
                  then "move workspace to output left"
                  else "move workspace to output right";
              }) (dirs.left ++ dirs.right)
            );
          in
            workspaceBindings
            // moveWorkspaceBindings
            // swapWorkspaceBindings
            // directional
            // moveDirectional
            // moveDirectionalNomode
            // focusOutputs
            // moveWorkspaceOutputs
            // {
              "${mod}+Return" = "exec ${terminal}";
              "${mod}+e" = "exec ${filemanager}";
              "${mod}+q" = "kill";
              "${mod}+Shift+c" = "reload";

              "${mod}+Shift+e" = "exec ${scrollnag} -t warning -m 'You pressed the exit shortcut. Do you really want to exit scroll? This will end your Wayland session.' -B 'Yes, exit scroll' '${scrollmsg} exit' -w 500 -e center -y overlay";

              "${mod}+bracketleft" = "set_mode h";
              "${mod}+bracketright" = "set_mode v";

              "${mod}+Shift+Page_Up" = "workspace prev";
              "${mod}+Shift+Page_Down" = "workspace next";
              "${mod}+Page_Up" = "workspace prev_on_output";
              "${mod}+Page_Down" = "workspace next_on_output";

              "${mod}+Shift+backslash" = "mode wssplit";

              "${mod}+Shift+comma" = "scale_workspace incr -0.05";
              "${mod}+Shift+button4" = "scale_workspace incr -0.05";
              "${mod}+Shift+period" = "scale_workspace incr 0.05";
              "${mod}+Shift+button5" = "scale_workspace incr 0.05";
              "${mod}+Shift+Ctrl+period" = "scale_workspace reset";

              "${mod}+tab" = "scale_workspace overview";
              "${mod}+button8" = "scale_workspace overview";
              "${mod}+Shift+tab" = "scale_workspaces toggle";

              "${mod}+slash" = "mode jump";
              "${mod}+Shift+slash" = "mode filter";

              "${mod}+comma" = "scale_content incr -0.05";
              "${mod}+button4" = "scale_content incr -0.05";
              "${mod}+period" = "scale_content incr 0.05";
              "${mod}+button5" = "scale_content incr 0.05";
              "${mod}+Ctrl+period" = "scale_content reset";

              "${mod}+f" = "fullscreen";
              "${mod}+Ctrl+f" = "fullscreen layout";
              "${mod}+Alt+f" = "fullscreen application";
              "${mod}+Ctrl+Alt+f" = "fullscreen global";

              "${mod}+y" = "focus mode_toggle";
              "${mod}+Shift+y" = "layout_transpose";
              "${mod}+Shift+f" = "floating toggle";

              "${mod}+Shift+Ctrl+a" = "sticky toggle";
              "${mod}+a" = "pin beginning";
              "${mod}+Shift+a" = "pin end";

              "${mod}+Insert" = "selection toggle";
              "${mod}+Ctrl+Insert" = "selection reset";
              "${mod}+Shift+Insert" = "selection move";
              "${mod}+Ctrl+Shift+Insert" = "selection workspace";
              "${mod}+Alt+Insert" = "selection to_trail";

              "${mod}+Shift+z" = "move scratchpad";
              "${mod}+z" = "scratchpad show";
              "${mod}+Alt+z" = "scratchpad jump";
              "${mod}+Ctrl+z" = "workspace back_and_forth";

              "${mod}+backslash" = "mode modifiers";

              "${mod}+minus" = "cycle_size h prev";
              "${mod}+equal" = "cycle_size h next";
              "${mod}+Shift+minus" = "cycle_size v prev";
              "${mod}+Shift+equal" = "cycle_size v next";

              "${mod}+b" = "mode setsizeh";
              "${mod}+Shift+b" = "mode setsizev";

              "${mod}+Shift+r" = "mode resize";
              "${mod}+Ctrl+r" = "mode floating";

              "${mod}+t" = "toggle_size this 1.0 1.0";
              "${mod}+Shift+t" = "toggle_size active 1.0 1.0";

              "${mod}+Ctrl+t" = "mode togglesizeh";
              "${mod}+Ctrl+Shift+t" = "mode togglesizev";

              "${mod}+c" = "mode align";
              "${mod}+w" = "mode fit_size";

              "${mod}+semicolon" = "mode trailmark";
              "${mod}+Shift+semicolon" = "mode trail";
              "${mod}+g" = "mode spaces";
            };
          modes = let
            sizes = {
              "1" = 0.125;
              "2" = 0.1666666667;
              "3" = 0.25;
              "4" = 0.333333333;
              "5" = 0.375;
              "6" = 0.5;
              "7" = 0.625;
              "8" = 0.6666666667;
              "9" = 0.75;
              "10" = 0.833333333;
            };
            sizeOf = n: toString sizes.${toString n};
            resizeBindings = dirBindings {
              left = "resize shrink width 100px";
              down = "resize grow height 100px";
              up = "resize shrink height 100px";
              right = "resize grow width 100px";
            };
            resizeShiftBindings = dirBindings {
              prefix = "Shift+";
              left = "resize shrink right 100px";
              down = "resize grow down 100px";
              up = "resize shrink down 100px";
              right = "resize grow right 100px";
            };
            resizeCtrlBindings = dirBindings {
              prefix = "Ctrl+";
              left = "resize grow left 100px";
              down = "resize shrink up 100px";
              up = "resize grow up 100px";
              right = "resize shrink left 100px";
            };

            floatingMoveBindings = dirBindings {
              left = "move left 50px";
              down = "move down 50px";
              up = "move up 50px";
              right = "move right 50px";
            };
            floatingShiftBindings = dirBindings {
              prefix = "Shift+";
              left = "resize shrink right 50px";
              down = "resize grow down 50px";
              up = "resize shrink down 50px";
              right = "resize grow right 50px";
            };
            floatingCtrlBindings = dirBindings {
              prefix = "Ctrl+";
              left = "resize grow left 50px";
              down = "resize shrink up 50px";
              up = "resize grow up 50px";
              right = "resize shrink left 50px";
            };

            numericSetSizeH = numBindings {action = n: "set_size h ${sizeOf n}; mode default";};
            numericSetSizeV = numBindings {action = n: "set_size v ${sizeOf n}; mode default";};
            numericToggleSizeH = numBindings {action = n: "toggle_size all ${sizeOf n} 1.0; mode default";};
            numericToggleSizeV = numBindings {action = n: "toggle_size all 1.0 ${sizeOf n}; mode default";};

            fitSizeDirectional = dirBindings {
              left = "fit_size h tobeg proportional; mode default";
              down = "fit_size h all proportional; mode default";
              up = "fit_size h active proportional; mode default";
              right = "fit_size h toend proportional; mode default";
            };
            fitSizeShiftDirectional = dirBindings {
              prefix = "Shift+";
              left = "fit_size v tobeg proportional; mode default";
              down = "fit_size v all proportional; mode default";
              up = "fit_size v active proportional; mode default";
              right = "fit_size v toend proportional; mode default";
            };
            fitSizeCtrlDirectional = dirBindings {
              prefix = "Ctrl+";
              left = "fit_size h tobeg equal; mode default";
              down = "fit_size h all equal; mode default";
              up = "fit_size h active equal; mode default";
              right = "fit_size h toend equal; mode default";
            };
            fitSizeCtrlShiftDirectional = dirBindings {
              prefix = "Ctrl+Shift+";
              left = "fit_size v tobeg equal; mode default";
              down = "fit_size v all equal; mode default";
              up = "fit_size v active equal; mode default";
              right = "fit_size v toend equal; mode default";
            };
            modifierMode = {
              Right = "set_mode after; mode default";
              l = "set_mode after; mode default";

              Left = "set_mode before; mode default";
              h = "set_mode before; mode default";

              Home = "set_mode beginning; mode default";
              End = "set_mode end; mode default";

              Up = "set_mode focus; mode default";
              k = "set_mode focus; mode default";

              Down = "set_mode nofocus; mode default";
              j = "set_mode nofocus; mode default";

              "Shift+h" = "set_mode nocenter_horiz; mode default";

              v = "set_mode center_vert; mode default";
              "Shift+v" = "set_mode nocenter_vert; mode default";

              r = "set_mode reorder_auto; mode default";
              "Shift+r" = "set_mode noreorder_auto; mode default";

              w = "set_mode fitfraction; mode default";
              "Shift+w" = "set_mode fitsplit; mode default";
              "Ctrl+w" = "set_mode nofit; mode default";

              Escape = "mode default";
            };

            wsSplitMode = {
              "1" = "workspace split v 0.25 10; mode default";
              "Shift+1" = "workspace split h 0.25 10; mode default";
              "2" = "workspace split v 0.333333333 10; mode default";
              "Shift+2" = "workspace split h 0.333333333 10; mode default";
              "3" = "workspace split v 0.5 10; mode default";
              "Shift+3" = "workspace split h 0.5 10; mode default";
              "4" = "workspace split v 0.66666667 10; mode default";
              "Shift+4" = "workspace split h 0.6666667 10; mode default";
              "5" = "workspace split v 0.75 10; mode default";
              "Shift+5" = "workspace split h 0.75 10; mode default";
              r = "workspace split reset; mode default";
              Escape = "mode default";
            };

            jumpMode = {
              slash = "jump tiling; mode default";
              "Shift+slash" = "jump tiling all; mode default";
              c = "jump container; mode default";
              w = "jump workspaces; mode default";
              f = "jump floating; mode default";
              "Shift+f" = "jump floating all; mode default";
              a = "jump all; mode default";
              "Shift+a" = "jump all all; mode default";
              s = "scratchpad jump; mode default";
              t = "jump trailmark; mode default";
              "Shift+t" = "jump trailmark all; mode default";
              v = "jump; mode default";
              r = ''jump criteria [app_id="firefox"]; mode default'';
              Escape = "mode default";
            };

            filterMode = {
              slash = "filter active tiling; mode default";
              "Shift+slash" = "filter all tiling; mode default";
              "Ctrl+slash" = "filter active_only tiling; mode default";

              c = "filter active container; mode default";
              "Shift+c" = "filter all container; mode default";
              "Ctrl+c" = "filter active_only container; mode default";

              f = "filter active floating; mode default";
              "Shift+f" = "filter all floating; mode default";
              "Ctrl+f" = "filter active_only floating; mode default";

              t = "filter active trailmark; mode default";
              "Shift+t" = "filter all trailmark; mode default";
              "Ctrl+t" = "filter active_only trailmark; mode default";

              v = "filter active visible; mode default";
              "Shift+v" = "filter all visible; mode default";
              "Ctrl+v" = "filter active_only visible; mode default";

              r = "filter reset; mode default";
              Escape = "mode default";
            };

            trailmarkMode = {
              bracketright = "trailmark next";
              bracketleft = "trailmark prev";
              semicolon = "trailmark toggle; mode default";
              slash = "trailmark jump; mode default";
              Escape = "mode default";
            };

            trailMode =
              numBindings {action = n: "trail number ${toString n}; mode default";}
              // {
                bracketright = "trail next";
                bracketleft = "trail prev";
                semicolon = "trail new; mode default";
                d = "trail delete; mode default";
                c = "trail clear; mode default";
                Insert = "trail to_selection; mode default";
                Escape = "mode default";
              };

            spacesMode =
              numBindings {action = n: "space load ${toString n}; mode default";}
              // numBindings {
                prefix = "Shift+";
                action = n: "space save ${toString n}; mode default";
              }
              // numBindings {
                prefix = "Ctrl+";
                action = n: "space restore_hide ${toString n}; mode default";
              }
              // numBindings {
                prefix = "Ctrl+Shift+";
                action = n: "space restore ${toString n}; mode default";
              }
              // {Escape = "mode default";};
          in {
            wssplit = wsSplitMode;
            jump = jumpMode;
            filter = filterMode;
            modifiers = modifierMode;

            resize =
              resizeBindings
              // resizeShiftBindings
              // resizeCtrlBindings
              // {Escape = "mode default";};

            floating =
              floatingMoveBindings
              // floatingShiftBindings
              // floatingCtrlBindings
              // {Escape = "mode default";};

            setsizeh =
              numericSetSizeH
              // {
                minus = "set_size h 0.875; mode default";
                equal = "set_size h 1.0; mode default";
                Escape = "mode default";
              };

            setsizev =
              numericSetSizeV
              // {
                minus = "set_size v 0.875; mode default";
                equal = "set_size v 1.0; mode default";
                Escape = "mode default";
              };

            togglesizeh =
              numericToggleSizeH
              // {
                minus = "toggle_size all 0.875 1.0; mode default";
                equal = "toggle_size all 1.0 1.0; mode default";
                r = "toggle_size reset; mode default";
                Escape = "mode default";
              };

            togglesizev =
              numericToggleSizeV
              // {
                minus = "toggle_size all 1.0 0.875; mode default";
                equal = "toggle_size all 1.0 1.0; mode default";
                r = "toggle_size reset; mode default";
                Escape = "mode default";
              };

            align = {
              c = "align center; mode default";
              m = "align middle; mode default";
              r = "align reset; mode default";

              Left = "align left; mode default";
              h = "align left; mode default";

              Right = "align right; mode default";
              l = "align right; mode default";

              Up = "align up; mode default";
              k = "align up; mode default";

              Down = "align down; mode default";
              j = "align down; mode default";

              Escape = "mode default";
            };

            fit_size =
              fitSizeDirectional
              // fitSizeShiftDirectional
              // fitSizeCtrlDirectional
              // fitSizeCtrlShiftDirectional
              // {
                w = "fit_size h visible proportional; mode default";
                "Shift+w" = "fit_size v visible proportional; mode default";
                "Ctrl+w" = "fit_size h visible equal; mode default";
                "Ctrl+Shift+w" = "fit_size v visible equal; mode default";

                Escape = "mode default";
              };

            trailmark = trailmarkMode;
            trail = trailMode;
            spaces = spacesMode;
          };
        };
      };
    };
  };
}
