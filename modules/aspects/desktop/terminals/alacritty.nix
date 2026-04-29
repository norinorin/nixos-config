{
  den.aspects.alacritty = {
    homeManager = {lib, ...}: {
      programs.alacritty = {
        enable = true;
        settings = {
          window.opacity = lib.mkDefault 0.5;
          window.blur = true;
        };
      };
    };
  };
}
