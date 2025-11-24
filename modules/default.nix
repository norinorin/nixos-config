{ pkgs, ... }:
{
    imports = [
        ./niri.nix
        ./kanata.nix
        ./python.nix
        ./qtile.nix
        ./spotify.nix
        ./thunar.nix
    ];
}