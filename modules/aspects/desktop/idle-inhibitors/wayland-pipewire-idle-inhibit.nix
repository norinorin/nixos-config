{inputs, ...}: {
  flake-file.inputs.wayland-pipewire-idle-inhibit.url = "github:rafaelrc7/wayland-pipewire-idle-inhibit";

  den.aspects.wayland-pipewire-idle-inhibit = {
    homeManager = {lib, ...}: {
      imports = [inputs.wayland-pipewire-idle-inhibit.homeModules.default];

      services.wayland-pipewire-idle-inhibit = {
        enable = true;
        settings = {
          verbosity = "INFO";
          media_minimum_duration = 10;
          idle_inhibitor = "wayland";
          node_blacklist = [
            {
              name = "spotify";
              app_name = "spotify";
            }
            {name = "Chromium";}
            {media_role = "Music";}
          ];
        };
      };

      systemd.user.services.wayland-pipewire-idle-inhibit.Install.WantedBy = lib.mkForce [
        "niri.service"
        # "hyprland-session.target"
      ];
    };
  };
}
