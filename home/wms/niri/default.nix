{ pkgs, ... }: {
    home.packages = with pkgs; [
        wl-clipboard
        wayland-utils
        libsecret
        cage
        gamescope
        xwayland-satellite
        fuzzel
        grim 
    ];

    home.file.".config/niri/config.kdl".source = ./config.kdl;
}