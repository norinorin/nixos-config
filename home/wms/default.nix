{ desktop, lib, pkgs, ... }:
{
    imports = [ ]
    ++ lib.optional (desktop == "niri") ./niri
    ++ lib.optional (desktop == "hyprland") ./hyprland;

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
        systemd.enable = true;
    };
}