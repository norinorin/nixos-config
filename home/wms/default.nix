{pkgs, ...}: {
  imports = [
    ./niri
    ./hyprland
  ];

  home.packages = with pkgs; [
    wl-clipboard
    wayland-utils
    libsecret
    cage
    gamescope
    grim
  ];

  programs.waybar = {
    enable = true;
    systemd.enable = false;
  };

  # get rid of suspend as we can't even suspend with nvidia anyway
  # also get rid of lock cos it's more practical to use Sup+Alt L to lock via compositor
  # layout:
  # H | S | R
  #   | E |
  programs.wlogout = {
    enable = true;
    layout = [
      {
        label = "hibernate";
        action = "systemctl hibernate";
        text = "Hibernate";
        keybind = "h";
      }
      {
        label = "";
        action = "true";
        text = "";
        keybind = "";
      }
      {
        label = "shutdown";
        action = "systemctl poweroff";
        text = "Shutdown";
        keybind = "s";
      }
      {
        label = "logout";
        action = "loginctl terminate-user $USER";
        text = "Logout";
        keybind = "e";
      }
      {
        label = "reboot";
        action = "systemctl reboot";
        text = "Reboot";
        keybind = "r";
      }
      {
        label = "";
        action = "true";
        text = "";
        keybind = "";
      }
    ];
  };
}
