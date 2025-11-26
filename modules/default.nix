{
  lib,
  desktop,
  ...
}: {
  imports =
    [
      ./denoiser.nix
      ./kanata.nix
      ./python.nix
      ./spotify.nix
      ./thunar.nix
      ./steam.nix
      ./obs.nix
      ./vscode.nix
      ./prism-launcher.nix
      ./warp.nix
    ]
    ++ lib.optional (desktop == "niri") ./niri.nix
    ++ lib.optional (desktop == "hyprland") ./hyprland.nix;
}
