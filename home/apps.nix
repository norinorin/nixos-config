{ pkgs, ... }: {
    home.packages = with pkgs; [
        alacritty
        discord
        qbittorrent
    ];
}