{ pkgs, ... }: {
    home.packages = with pkgs; [
        xwayland-satellite
    ];

    home.file.".config/niri/config.kdl".source = ./config.kdl;
    services.swayidle.enable = true;
    home.sessionVariables.NIXOS_OZONE_WL = "1";
}