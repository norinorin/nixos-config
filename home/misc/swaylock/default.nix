{lib, ...}: {
  programs.swaylock = {
    enable = true;
    settings = {
      color = lib.mkDefault "1e1e2e";
      ring-color = lib.mkDefault "a6e3a1";
      inside-color = lib.mkDefault "94e2d5";
      line-color = lib.mkDefault "f9e2af";
      separator-color = lib.mkDefault "fab387";
    };
  };
}
