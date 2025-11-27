{pkgs, ...}: {
  home.packages = with pkgs; [
    qbittorrent
    audacity
    cloudflare-warp
    zotero
    (osu-lazer-bin.override
      {
        nativeWayland = true;
      })
    gnome-clocks
  ];
}
