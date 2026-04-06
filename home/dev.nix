{pkgs, ...}: {
  home.packages = with pkgs; [
    gcc
    neovim
    alejandra
    ruff
    nil
    heroku
    uv

    rustup
    rustc
    cargo
    rust-analyzer
    rustfmt
    clippy

    (python3.withPackages (python-pkgs:
      with python-pkgs; [
        pandas
        requests
      ]))
    python311
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
          "[rust]" = {
            "editor.defaultFormatter" = "rust-lang.rust-analyzer";
            "editor.formatOnSave" = true;
          };
          "rust-analyzer.check.command" = "clippy";
          "rust-analyzer.cargo.sysroot" = "discover";
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

          rust-lang.rust-analyzer
          tamasfe.even-better-toml

          shd101wyy.markdown-preview-enhanced
          prettier.prettier-vscode
        ];
      };
    };
  };
}
