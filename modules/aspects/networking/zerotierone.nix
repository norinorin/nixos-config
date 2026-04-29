{
  lib,
  den,
  ...
}: {
  den.aspects.zerotierone = {
    nixos = {
      services = {
        zerotierone = {
          enable = true;
          joinNetworks = [
            "2873fd00f2dc345a"
            "166359304ea191b2"
          ];
        };
      };
    };

    nixosOtg = {
      services.zerotierone.enable = lib.mkForce false;
    };
  };
}
