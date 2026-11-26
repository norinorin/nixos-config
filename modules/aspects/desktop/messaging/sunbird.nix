{...}: {
  den.aspects.sunbird = {
    homeManager = {pkgs, ...}: let
      pname = "sunbird";
      version = "2233";

      src = pkgs.fetchurl {
        url = "https://dl.redeem.saarland/desktop/${version}/linux-x64.AppImage";
        sha256 = "73808ee53da2ef0dc984571840bec0ed3311fa9e2ef1236ca01c5cd82f559abe";
      };

      libphoenix = pkgs.rustPlatform.buildRustPackage {
        pname = "libphoenix";
        version = "0-unstable-pr37-pr39";

        # hacky af
        # FIXME: remove once fixes are merged
        src =
          pkgs.runCommand "sunbird-src" {
            nativeBuildInputs = [
              pkgs.git
              pkgs.cacert
            ];
            outputHashMode = "recursive";
            outputHashAlgo = "sha256";
            outputHash = "sha256-paU0WyzpSTjYPSJOBew81i49yB3YrNs3ptgUbpZf+dw=";
          } ''
            base=10f30b3390d52d12e23e28ead49dcca8e2df32ef
            git init "$out"
            cd "$out"
            git remote add origin https://github.com/sunbird-tools/sunbird.git
            git fetch origin \
              "$base" \
              refs/pull/37/head \
              refs/pull/39/head
            git checkout "$base"
            git -c user.name=nix -c user.email=nix@localhost merge --no-edit d658090c083152e71aec555c5ad195289da6e85d
            git -c user.name=nix -c user.email=nix@localhost merge --no-edit 3061bb2662a6895eed2835c145caaa97c4cfca22
            rm -rf .git
          '';

        cargoHash = "sha256-zvsr8LAnZhCTQlgNPgoENyDXtcV8hKPu9s8Ry888xbE=";

        buildAndTestSubdir = "crates/loader";
        cargoBuildFlags = ["--lib"];
        doCheck = false;

        nativeBuildInputs = [
          pkgs.pkg-config
          pkgs.cmake
          pkgs.rustPlatform.bindgenHook
        ];

        buildInputs = [
          pkgs.sqlite
        ];

        installPhase = ''
          runHook preInstall
          install -Dm755 target/*/release/lib*.so "$out/lib/libphoenix.so"
          runHook postInstall
        '';
      };

      appimageContents = pkgs.appimageTools.extract {
        inherit pname version src;
      };

      extraLibs = p: [
        p.libva
        p.vulkan-loader
        p.wayland
        p.libxkbcommon
        p.libglvnd
      ];

      desktopItem = pkgs.makeDesktopItem {
        name = "sunbird";
        desktopName = "Sunbird";
        comment = "Discord Phoenix with Sunbird";
        exec = "sunbird %U";
        icon = "sunbird";
        terminal = false;
        categories = [
          "Network"
          "InstantMessaging"
        ];
        mimeTypes = ["x-scheme-handler/discord"];
      };

      wrapper = pkgs.writeShellScript "sunbird-wrapper" ''
        while [ "''${1:-}" = "--no-runtime" ] || [ "''${1:-}" = "--gate-only" ]; do
          export SUNBIRD_GATE_ONLY=1
          shift
        done

        export LD_PRELOAD="${libphoenix}/lib/libphoenix.so''${LD_PRELOAD:+:$LD_PRELOAD}"
        exec ${appimageContents}/AppRun "$@"
      '';

      sunbird = pkgs.buildFHSEnv (
        pkgs.appimageTools.defaultFhsEnvArgs
        // {
          name = pname;
          inherit pname version;

          targetPkgs = p:
            (pkgs.appimageTools.defaultFhsEnvArgs.targetPkgs p)
            ++ (extraLibs p);

          multiPkgs = p:
            (pkgs.appimageTools.defaultFhsEnvArgs.multiPkgs p)
            ++ (extraLibs p);

          runScript = wrapper;

          extraInstallCommands = ''
            mkdir -p $out/share/applications
            cp ${desktopItem}/share/applications/* $out/share/applications/

            if [ -e "${appimageContents}/.DirIcon" ]; then
              install -Dm444 "${appimageContents}/.DirIcon" "$out/share/icons/hicolor/256x256/apps/sunbird.png"
            fi
          '';

          meta = {
            description = "Discord Phoenix preloaded with the Sunbird runtime";
            platforms = ["x86_64-linux"];
            mainProgram = "sunbird";
          };
        }
      );
    in {
      home.packages = [sunbird];
    };
  };
}
