{ pkgs, ... }: {
    programs = {
        niri = {
            enable = true;
            package = pkgs.niri;
        };
        waybar.enable = true;
    };
}