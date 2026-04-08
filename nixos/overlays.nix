{
  inputs,
  pkgs-unstable,
  ...
}: {
  nixpkgs.overlays = [
    inputs.anime_rpc.overlays.default
    inputs.niri.overlays.niri

    (import ../overlays/undervolt.nix)
    (import ../overlays/spotx.nix {inherit pkgs-unstable;})
    (import ../overlays/obsidian.nix)
    (import ../overlays/tricat.nix)
  ];
}
