# Currently the docker container is setup manually.
# I don't think there's any use case yet that justifies making nix manage it.
# Since we already have rootless docker setup in nixos/virt.nix:
# 1. `systemctl --user start docker`
# 2. Then follow https://github.com/winapps-org/winapps/blob/main/docs/docker.md
#
# Note to self: prolly wanna change VERSION to tiny11
{inputs, ...}: {
  flake-file.inputs.winapps = {
    url = "github:winapps-org/winapps";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  den.aspects.winapps = {
    nixos = {pkgs, ...}: let
      inherit (pkgs.stdenv.hostPlatform) system;
    in {
      environment.systemPackages = [
        pkgs.freerdp
        (inputs.winapps.packages."${system}".winapps.overrideAttrs (old: {
          postPatch =
            (old.postPatch or "")
            + ''
              substituteInPlace bin/winapps \
                --replace 'readonly SCRIPT_DIR_PATH=' \
                          "readonly SCRIPT_DIR_PATH=\"$out/src/bin\" #"
            '';
        }))
        inputs.winapps.packages."${system}".winapps-launcher
      ];
    };
  };
}
