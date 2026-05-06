{
  den.aspects.upower = {
    nixos = {pkgs, ...}: {
      services.upower.enable = true;
      environment.systemPackages = [pkgs.upower];
    };
  };
}
