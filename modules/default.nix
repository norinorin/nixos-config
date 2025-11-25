{ pkgs, lib, desktop, ... }:
{
    imports = [
        ./denoiser.nix
        ./kanata.nix
        ./python.nix
        ./qtile.nix
        ./spotify.nix
        ./thunar.nix
        ./steam.nix
    ] 
    ++ lib.optional (desktop == "niri") ./niri.nix
    ++ lib.optional (desktop == "hyprland") ./hyprland.nix;
}