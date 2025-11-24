{ pkgs, ... }: {
    home.packages = with pkgs; [
        gcc
        neovim
        vscode
    ];
}