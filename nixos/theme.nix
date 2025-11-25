{ pkgs, ... }:
{
    stylix = {
        enable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest.yaml";
        autoEnable = true;
        opacity.applications = 0.95;
        opacity.desktop = 0.5;
        opacity.terminal = 0.6;
        fonts.monospace = {
            name = "JetBrains Mono";
            package = pkgs.nerd-fonts.jetbrains-mono;
        };
    };

    environment.systemPackages = [
        pkgs.bibata-cursors
    ];
}