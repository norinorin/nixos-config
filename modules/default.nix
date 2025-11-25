{ pkgs, ... }:
{
    imports = [
        ./denoiser.nix
        ./niri.nix
        ./kanata.nix
        ./python.nix
        ./qtile.nix
        ./spotify.nix
        ./thunar.nix
        ./steam.nix
    ];
}