{
  pkgs,
  pkgs-unstable,
  lib,
  ...
}: let
  smooth-scroll = pkgs.fetchFromGitHub {
    owner = "thomasschafer";
    repo = "smooth-scroll.hx";
    rev = "1ed8b088e465fb139389c36ad158ba4a2d9e1bbc";
    hash = "sha256-4lxGZrT4cEcg3jqae3uJGGGCSy4WeVZeJ0hIApMb7jY=";
  };
  presence-hx = pkgs.fetchFromGitHub {
    owner = "Ciflire";
    repo = "presence.hx";
    rev = "5b5f134c30c3a3d9a6f3565e8cc56973230bc7ef";
    hash = "sha256-L+fExKl4X1BHi+BIKHgBPtqyHHjqAc0qwyvCq8c0B0E=";
  };
  presence-lib = pkgs.rustPlatform.buildRustPackage {
    pname = "helix-discord-rpc";
    version = "5b5f134";
    src = presence-hx;
    cargoHash = "sha256-YnAQ1NFP3hEV/nNK/L8TGpOgqXTU/40WpFbFd5kHizA=";
    buildType = "release";
    installPhase = ''
      mkdir -p $out/lib
      find . -name "libhelix_discord_rpc.so" -exec cp {} $out/lib/ \;
    '';
    doCheck = false;
  };
in {
  home.packages = with pkgs; [
    gcc
    alejandra
    nil
    ruff
    uv
    (python3.withPackages (python-pkgs:
      with python-pkgs; [
        pandas
        requests
      ]))
    (lib.lowPrio python311)
    heroku
    lazygit
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

    helix = {
      enable = true;
      package = pkgs-unstable.steelix;

      settings = {
        editor = {
          cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
        };
        keys.normal = {
          C-j = ":half-page-down-smooth";
          C-k = ":half-page-up-smooth";
          pageup = ":page-up-smooth";
          pagedown = ":page-down-smooth";
          C-t = ":sh $TERMINAL"; # $TERMINAL is set in users/<user>.nix
          C-g = [
            ":write-all"
            ":insert-output lazygit >/dev/tty"
            ":redraw"
            ":reload-all"
          ];
          space.e = [
            ":sh rm -f /tmp/unique-file-h21a434"
            ":insert-output ${pkgs.yazi}/bin/yazi \"%{buffer_name}\" --chooser-file=/tmp/unique-file-h21a434"
            ":sh printf \"\x1b[?1049h\x1b[?2004h\" > /dev/tty"
            ":open %sh{cat /tmp/unique-file-h21a434}"
            ":redraw"
          ];
        };
      };

      languages = {
        language-server = {
          rust-analyzer = {
            command = "rust-analyzer";
            config = {
              check = {command = "clippy";};
              cargo = {sysroot = "discover";};
            };
          };
          nil = {
            command = "nil";
            config = {
              nil.formatting.command = ["alejandra"];
            };
          };
          basedpyright = {
            command = "${pkgs.basedpyright}/bin/basedpyright-langserver";
            args = ["--stdio"];
          };
          ruff = {
            command = "ruff";
            args = ["server"];
          };
          mpls = {
            command = "${pkgs.mpls}/bin/mpls";
          };
          marksman = {
            command = "${pkgs.marksman}/bin/marksman";
          };
        };

        language = [
          {
            name = "python";
            auto-format = true;
            language-servers = ["basedpyright" "ruff"];
            formatter = {
              command = lib.getExe pkgs.ruff;
              args = ["format" "-"];
            };
          }
          {
            name = "rust";
            auto-format = true;
            language-servers = ["rust-analyzer"];
          }
          {
            name = "nix";
            auto-format = true;
            language-servers = ["nil"];
            formatter = {
              command = lib.getExe pkgs.alejandra;
            };
          }
          {
            name = "markdown";
            language-servers = ["marksman" "mpls"];
          }
        ];
      };
    };
  };

  # do i really have to do this?
  # i just want --tutor mane
  xdg.configFile = {
    "helix/runtime/tutor".source = "${pkgs-unstable.steelix.src}/runtime/tutor";
    "helix/runtime/themes".source = "${pkgs-unstable.steelix.src}/runtime/themes";
    "helix/runtime/queries".source = "${pkgs-unstable.helix}/lib/runtime/queries";
    "helix/runtime/grammars".source = "${pkgs-unstable.helix}/lib/runtime/grammars";
  };

  # helix plugins
  xdg.configFile."helix/plugins/smooth-scroll.hx".source = smooth-scroll;
  xdg.configFile."helix/plugins/presence.hx".source = presence-hx;
  xdg.configFile."helix/init.scm".text = ''
    (require "plugins/smooth-scroll.hx/smooth-scroll.scm")
    (require "plugins/presence.hx/helix-discord-rpc.scm")
  '';
  home.file = {
    ".steel/native/libhelix_discord_rpc.so".source = "${presence-lib}/lib/libhelix_discord_rpc.so";
  };
}
