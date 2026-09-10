{inputs, ...}: {
  flake-file.inputs.windscribe = {
    url = "github:Varmisanth/windscribe-nixos";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.windscribe = {
    nixos = {
      imports = [inputs.windscribe.nixosModules.windscribe];

      # this likely does nothing since we're using nixpkgs-unstable?
      nix.settings = {
        substituters = ["https://varmisanth.cachix.org"];
        trusted-public-keys = ["varmisanth.cachix.org-1:rt04yjDDJKDWe+h6B1XQWfdsSDUX6uks+9IKVBjn2d8="];
      };

      programs.windscribe = {
        enable = true;
        users = ["nori"];
        settings = {
          # for some reason we have to set it to NetworkManager otherwise it won't connect
          dnsPolicy = "os-default";
          dnsManager = "networkmanager";
          connectedDns = {
            # managed by dns-crypt
            type = "custom";
            upStream1 = "127.0.0.1";
          };
        };
      };
    };
  };
}
