{pkgs, ...}: {
  home.packages = with pkgs; [
    gcc
    neovim
    alejandra
    ruff
    nil
  ];

  programs = {
    vscode = {
      enable = true;
      profiles.default = {
        userSettings = {
          "editor.formatOnSave" = true;
          "[python]" = {
            "editor.defaultFormatter" = "charliermarsh.ruff";
            "editor.formatOnSave" = true;
            "editor.codeActionsOnSave"."source.organizeImports" = "explicit";
          };
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "nil";
          "nix.serverSettings" = {
            nil = {
              formatting.command = ["alejandra"];
            };
          };
        };
        extensions = with pkgs.vscode-marketplace; [
          jnoortheen.nix-ide
          arrterian.nix-env-selector
          sainnhe.everforest

          ms-python.python
          charliermarsh.ruff
          detachhead.basedpyright

          shd101wyy.markdown-preview-enhanced
          prettier.prettier-vscode
        ];
      };
    };
  };
}
