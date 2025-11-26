{lib, ...}: {
  programs.alacritty = {
    enable = true;
    settings = {
      window.opacity = lib.mkDefault 0.5;
    };
  };
}
