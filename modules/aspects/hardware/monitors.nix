{
  den.aspects.monitors = {
    nixos = {pkgs, ...}: {
      hardware.i2c.enable = true;
      environment.systemPackages = [pkgs.ddcutil];
    };

    provides.to-users = {user, ...}: {
      nixos.users.users."${user.userName}" = ["i2c"];
    };
  };
}
