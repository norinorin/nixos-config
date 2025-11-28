{lib, ...}: {
  boot.kernelModules = ["msr"];
  nixpkgs.overlays = [(import ../overlays/undervolt.nix)];
  services.undervolt = {
    enable = true;
    coreOffset = -95;
    uncoreOffset = -95;
    turbo = 0;
    temp = 97;
    p1 = {
      limit = 95;
      window = 56;
    };
    p2 = {
      limit = 162;
      window = 28;
    };
  };
  specialisation.on-the-go.configuration = {
    system.nixos.tags = ["on-the-go"];
    services.undervolt = {
      turbo = lib.mkForce 1;
      temp = lib.mkForce 85;
      p1.limit = lib.mkForce 45;
      p2.limit = lib.mkForce 45;
      gpuOffset = lib.mkForce (-50);
    };
  };
}
