{ lib, config, ... }:
{
    imports = [
        ./dunst
        ./swayidle
        ./swaylock
    ];

    services.swayosd.enable = true;

    programs.fuzzel = {
        enable = true;
        settings = {
            main = {
                match-mode = "fuzzy";
                font = lib.mkForce "Azeret Mono:size=10";
                exit-on-keyboard-focus-loss = false;
                line-height = 24;
            };
            colors.background = lib.mkForce "${config.lib.stylix.colors.base00}80";
        };
    };
}