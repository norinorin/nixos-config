{
    home.file.".config/waybar.modules" = {
        source = ./modules;
        recursive = true;
        executable = true;
    };
    home.file.".config/waybar/presets" = {
        source = ./presets;
        recursive = true;
        executable = true;
    };
    home.file.".config/waybar/watchers" = {
        source = ./watchers;
        recursive = true;
        executable = true;
    };
    home.file.".config/waybar/default.css".source = ./default.css;
    home.file.".config/waybar/mocha.css".source = ./mocha.css;
    home.file.".config/waybar/startwaybar" = {
        source = ./startwaybar;
        executable = true;
    };
}