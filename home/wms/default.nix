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
    wlogout
  ];

  programs.waybar = {
    enable = true;
    systemd.enable = false;
  };
}
