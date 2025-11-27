{pkgs, ...}: {
  home.packages = with pkgs; [
    qbittorrent
    audacity
    cloudflare-warp
    zotero
  ];
}
