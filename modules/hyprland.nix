{ inputs, pkgs, ... }:
let
    pkgs-hypr = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system};
    pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
    programs.hyprland = {
        enable = true;
        package = pkgs-hypr.hyprland;
        portalPackage = pkgs-hypr.xdg-desktop-portal-hyprland;
    };

    hardware.graphics = {
        package = pkgs-unstable.mesa;
        enable32Bit = true;
        package32 = pkgs-unstable.pkgsi686Linux.mesa;
    };
}