{pkgs, ...}: {
  home.file."wallpapers" = {
    source = ../wallpapers;
    recursive = true;
  };
  home.file."wally" = {
    source = ./wally;
    executable = true;
  };
}
