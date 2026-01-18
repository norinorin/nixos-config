{inputs, ...}: {
  nixpkgs.overlays = [
    inputs.anime_rpc.overlays.default
    inputs.niri.overlays.niri

    (import ../overlays/undervolt.nix)
    (import ../overlays/spotx.nix)
    (import ../overlays/obsidian.nix)
  ];
}
