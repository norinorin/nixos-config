{pkgs, ...}: {
  home.packages = with pkgs; [
    qbittorrent
    audacity
    cloudflare-warp
    (osu-lazer-bin.override
      {
        nativeWayland = true;
      })
    gnome-clocks
    zotero-beta
    xarchiver
    zip
    unzip
    (heroic.override {
      extraPkgs = pkgs: [
        pkgs.gamescope
        pkgs.gamemode
      ];
    })
  ];
}
