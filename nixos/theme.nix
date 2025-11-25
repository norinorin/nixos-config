{ pkgs, ... }:
{
    stylix = {
        enable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest.yaml";
        autoEnable = true;
    };

    environment.systemPackages = [
        pkgs.bibata-cursors
    ];
}