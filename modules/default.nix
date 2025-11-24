{ pkgs, ... }:
{
    imports = [
        ./niri.nix
        ./python.nix
        ./qtile.nix
    ];
}