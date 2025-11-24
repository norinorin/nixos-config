{ pkgs, ... }: {
    nixpkgs.overlays = [ (import ../overlays/spotx.nix) ];
    environment.systemPackages = [pkgs.spotify];
}