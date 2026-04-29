{inputs, ...}: {
  flake-file.inputs.helix-discord-rpc = {
    url = "github:norinorin/helix-discord-rpc";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.helix = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: let
      smooth-scroll = pkgs.fetchFromGitHub {
        owner = "thomasschafer";
        repo = "smooth-scroll.hx";
        rev = "1ed8b088e465fb139389c36ad158ba4a2d9e1bbc";
        hash = "sha256-4lxGZrT4cEcg3jqae3uJGGGCSy4WeVZeJ0hIApMb7jY=";
      };
      helix-discord-rpc = inputs.helix-discord-rpc.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in {
      programs.helix = {
        enable = true;
        package = pkgs.unstable.steelix;

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
            # these commands will be available via nix shell
            rust-analyzer = {
              command = "rust-analyzer";
              config = {
                check = {command = "clippy";};
                cargo = {sysroot = "discover";};
              };
            };
            nil = {
              command = lib.getExe pkgs.nil;
              config = {
                nil.formatting.command = [(lib.getExe pkgs.alejandra)];
              };
            };
            basedpyright = {
              command = "${pkgs.basedpyright}/bin/basedpyright-langserver";
              args = ["--stdio"];
            };
            ruff = {
              command = lib.getExe pkgs.ruff;
              args = ["server"];
            };
            mpls = {
              command = "${pkgs.mpls}/bin/mpls";
            };
            marksman = {
              command = "${pkgs.marksman}/bin/marksman";
            };
            scheme-langserver = {
              command = "${pkgs.akkuPackages.scheme-langserver}/bin/scheme-langserver";
            };
            typescript-language-server = {
              command = "${pkgs.typescript-language-server}/bin/typescript-language-server";
            };
            eslint = {
              command = "${pkgs.eslint}/bin/eslint";
            };
            deno = {
              command = "${pkgs.deno}/bin/deno";
              args = ["lsp"];
            };
            vscode-json-language-server = {
              command = "${pkgs.vscode-langservers-extracted}/bin/vscode-json-language-server";
            };
            vscode-html-language-server = {
              command = "${pkgs.vscode-langservers-extracted}/bin/vscode-html-language-server";
            };
            vscode-css-language-server = {
              command = "${pkgs.vscode-langservers-extracted}/bin/vscode-css-language-server";
            };
            tombi = {
              command = "${pkgs.tombi}/bin/tombi";
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
              auto-format = true;
              language-servers = ["marksman" "mpls"];
              soft-wrap.enable = true;
            }
            {
              name = "scheme";
              auto-format = true;
              language-servers = ["scheme-langserver"];
              formatter = {
                command = lib.getExe pkgs.schemat;
              };
              file-types = ["scm" "ss" "lisp" "rkt"];
            }
            {
              name = "typescript";
              auto-format = true;
              language-servers = ["typescript-language-server" "eslint"];
              formatter = {
                command = lib.getExe pkgs.dprint;
                args = ["fmt" "--stdin" "typescript"];
              };
            }
            {
              name = "javascript";
              auto-format = true;
              language-servers = ["typescript-language-server" "eslint"];
              formatter = {
                command = lib.getExe pkgs.dprint;
                args = ["fmt" "--stdin" "javascript"];
              };
            }
            {
              name = "jsx";
              auto-format = true;
              language-servers = ["typescript-language-server" "eslint"];
              formatter = {
                command = lib.getExe pkgs.dprint;
                args = ["fmt" "--stdin" "jsx"];
              };
            }
            {
              name = "tsx";
              auto-format = true;
              language-servers = ["deno" "eslint"];
              formatter = {
                command = lib.getExe pkgs.dprint;
                args = ["fmt" "--stdin" "tsx"];
              };
            }
            {
              name = "json";
              auto-format = true;
              language-servers = ["vscode-json-language-server"];
              formatter = {
                command = lib.getExe pkgs.dprint;
                args = ["fmt" "--stdin" "json"];
              };
              file-types = ["json" "jsonl"];
              soft-wrap.enable = true;
            }
            {
              name = "html";
              auto-format = true;
              language-servers = ["vscode-html-language-server"];
              formatter = {
                command = lib.getExe pkgs.prettier;
                args = ["--parser" "html"];
              };
              soft-wrap.enable = true;
            }
            {
              name = "css";
              auto-format = true;
              language-servers = ["vscode-css-language-server"];
              formatter = {
                command = lib.getExe pkgs.prettier;
                args = ["--parser" "css"];
              };
            }
            {
              name = "toml";
              auto-format = true;
              language-servers = ["tombi"];
              soft-wrap.enable = true;
            }
          ];
        };
      };

      # do i really have to do this?
      # i just want --tutor mane
      xdg.configFile = {
        "helix/runtime/tutor".source = "${pkgs.unstable.steelix.src}/runtime/tutor";
        "helix/runtime/themes".source = "${pkgs.unstable.steelix.src}/runtime/themes";
        "helix/runtime/queries".source = "${pkgs.unstable.helix}/lib/runtime/queries";
        "helix/runtime/grammars".source = "${pkgs.unstable.helix}/lib/runtime/grammars";
      };

      # helix plugins
      xdg.configFile."helix/plugins/smooth-scroll.hx".source = smooth-scroll;
      xdg.configFile."helix/plugins/helix-discord-rpc".source = "${helix-discord-rpc}/share/helix-discord-rpc";
      xdg.configFile."helix/init.scm".text = ''
        (require "plugins/smooth-scroll.hx/smooth-scroll.scm")
        (require "plugins/helix-discord-rpc/helix-discord-rpc.scm")
        (require "plugins/helix-discord-rpc/utils.scm")

        (discord-rpc-register-details-fn
          (lambda ()
            "In a workspace"))

        (require-builtin steel/strings)

        ; naive impl
        (define (a-or-an word)
          (let ([w (string-downcase word)])
            (if (or (starts-with? w "a")
                 (starts-with? w "e")
                 (starts-with? w "i")
                 (starts-with? w "o")
                 (starts-with? w "u"))
              "an"
              "a")))

        (discord-rpc-register-state-fn
          (lambda ()
            (let ([lang (discord-rpc-current-language)])
              (if (string=? lang "")
                "Editing a file"
                (string-append
                  "Editing "
                  (a-or-an lang)
                  " "
                  lang
                  " file")))))

        (discord-rpc-connect)
      '';
      home.file = {
        ".steel/native/libhelix_discord_rpc.so".source = "${helix-discord-rpc}/lib/libhelix_discord_rpc.so";
      };
    };
  };
}
