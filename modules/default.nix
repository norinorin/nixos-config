{
  pkgs,
  lib,
  displayManager,
  ...
}: let
  dmEnable = name: lib.mkIf (displayManager == name) {enable = true;};
in {
  imports = [
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

    # wms
    ./niri.nix
    ./hyprland.nix

    # display managers
    # ./ly.nix # we haven't got a rice for ly
    ./sddm.nix
  ];

  # install both so they survive nh clean
  environment.systemPackages = with pkgs; [
    ly
    kdePackages.sddm
  ];

  services.displayManager = {
    ly = dmEnable "ly";
    sddm = dmEnable "sddm";
  };
}
