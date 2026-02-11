{
  pkgs,
  inputs,
  ...
}: let
  gamePkgs = inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system};
in {
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
    rar
    mission-center
    yt-dlp
    (heroic.override {
      extraPkgs = pkgs: [
        pkgs.gamescope
        pkgs.gamemode
      ];
    })
    calibre
    obsidian
    libreoffice
    spotify
    tricat
    gamePkgs.osu-stable
  ];
}
