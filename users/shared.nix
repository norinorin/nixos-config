{username, ...}: {
  home = {
    inherit username;

    homeDirectory = "/home/${username}";
    stateVersion = "25.05";
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/${username}/Dotfiles";
  };
}
