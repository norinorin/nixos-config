{pkgs, ...}: {
  home.packages = with pkgs; [
    alacritty
    qbittorrent
    audacity
    cloudflare-warp
  ];
}
