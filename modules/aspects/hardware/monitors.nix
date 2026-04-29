{
  den.aspects.monitors = {
    nixos = {pkgs, ...}: {
      hardware.i2c.enable = true;
      environment.systemPackages = [pkgs.ddcutil];
    };

    users.extraGroups = ["i2c"];
  };
}
