{
  pkgs,
  config,
  ...
}: let
  rebuild = "sudo nixos-rebuild switch --flake ~/Dotfiles#toaster";
  killall = "function _killall(){ ps aux | grep \"[ ]\$1\" | awk '{print \$2}' | xargs kill; }; _killall";
in {
  imports = [
    ./shared.nix
    ../home
  ];

  programs.git = {
    enable = true;

    userName = "Nori";
    userEmail = "norizon16@proton.me";

    signing = {
      key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      signByDefault = true;
    };

    extraConfig.gpg = {
      format = "ssh";
    };
  };

  programs.thefuck.enable = true;
  programs.pay-respects.enable = true;

  programs.bash = {
    enable = true;
    shellAliases = {
      rbd = "${rebuild}";
      killall = "${killall}";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      rbd = "${rebuild}";
      killall = "${killall}";
      la = "ls -lah";
    };

    history.size = 10000;
    history.ignoreAllDups = true;
    history.path = "$HOME/.zsh_history";
    history.ignorePatterns = ["rm *" "pkill *" "cp *"];

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "thefuck"
        "python"
      ];
      theme = "wedisagree";
    };
  };

  home.pointerCursor = {
    # x11.enable = true;
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 16;
  };

  gtk = {
    enable = true;

    iconTheme = {
      name = "candy-icons";
      package = pkgs.candy-icons;
    };
  };

  xfconf.settings = {
    xfce4-session = {
      "general/TerminalEmulator" = "alacritty";
    };
  };
}
