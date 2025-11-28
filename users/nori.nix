{
  inputs,
  pkgs,
  config,
  ...
}: let
  nhs = "nh os switch ~/Dotfiles";
  nhus = "nh os switch -u ~/Dotfiles";
  nhc = "nh clean all";
  killall = "function _killall(){ ps aux | grep \"[ ]\$1\" | awk '{print \$2}' | xargs kill; }; _killall";
in {
  imports = [
    ./shared.nix
    ../home

    inputs.nixcord.homeModules.nixcord
    inputs.anime_rpc.homeModules.anime_rpc
  ];

  programs.git = {
    enable = true;

    signing = {
      key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      signByDefault = true;
    };

    settings = {
      gpg.format = "ssh";
      user = {
        name = "Nori";
        email = "norizon16@proton.me";
      };
    };
  };

  programs.pay-respects.enable = true;

  programs.bash = {
    enable = true;
    shellAliases = {
      inherit nhs nhus nhc killall;
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      inherit nhs nhus nhc killall;
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

  stylix.targets.qt.platform = "gnome";
}
