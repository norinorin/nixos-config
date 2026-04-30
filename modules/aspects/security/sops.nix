{inputs, ...}: {
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.sops = {
    nixos = {pkgs, ...}: {
      imports = [inputs.sops-nix.nixosModules.sops];

      environment.systemPackages = [pkgs.sops];

      sops.defaultSopsFile = ../../../secrets/secrets.yaml;
      sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      sops.age.generateKey = true;
    };

    provides.nori = {
      nixos = {
        sops.secrets."openweather/key" = {owner = "nori";};
        sops.secrets."openweather/lat" = {owner = "nori";};
        sops.secrets."openweather/lon" = {owner = "nori";};

        sops.secrets."ssh/main" = {
          path = "/home/nori/.ssh/id_ed25519";
          owner = "nori";
          mode = "0400";
        };
        sops.secrets."ssh/school" = {
          path = "/home/nori/.ssh/gh-school";
          owner = "nori";
          mode = "0400";
        };
      };
    };
  };
}
