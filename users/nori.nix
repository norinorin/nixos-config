{
  inputs,
  pkgs,
  config,
  ...
}: let
  nhs = "nh os switch ~/Dotfiles";
  nhus = "nh os switch -u ~/Dotfiles";
  nhb = "nh os boot ~/Dotfiles";
  nhc = "nh clean all --optimise";
  wcs = "warp-cli status";
  wcc = "warp-cli connect";
  wcd = "warp-cli disconnect";
  killall = "function _killall(){ ps aux | grep \"[ ]\$1\" | awk '{print \$2}' | xargs kill; }; _killall";
in {
  imports = [
    ./shared.nix
    ../home

    inputs.nix-index-database.homeModules.default
  ];

  programs = {
    nix-index-database.comma.enable = true;

    git = {
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

    ssh = {
      enable = true;

      matchBlocks = {
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = "~/.ssh/id_ed25519";
          identitiesOnly = true;
        };

        "github-school" = {
          hostname = "github.com";
          user = "git";
          identityFile = "~/.ssh/gh-school";
          identitiesOnly = true;
        };
      };
    };

    bash = {
      enable = true;
      shellAliases = {
        inherit nhs nhus nhb nhc killall wcc wcd wcs;
      };
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        inherit nhs nhus nhb nhc killall wcc wcd wcs;
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

  home.sessionVariables = {
    EDITOR = "vim";
    TERMINAL = "alacritty";
  };

  stylix.targets.qt.enable = false;
}
