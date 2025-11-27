{pkgs, ...}: {
  nixpkgs.overlays = [(import ../overlays/zotero-beta.nix)];
  environment.systemPackages = [pkgs.zotero-beta];
}
