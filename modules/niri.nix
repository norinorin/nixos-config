{ pkgs, ... }:
{
  programs = {
    niri = {
      enable = true;
      package = pkgs.niri;
    };
    waybar.enable = true;
  }

  packages = with pkgs; [
    wl-clipboard
    wayland-utils
    libsecret
    cage
    gamescope
    xwayland-satellite
    fuzzel
    grim 
  ]
}