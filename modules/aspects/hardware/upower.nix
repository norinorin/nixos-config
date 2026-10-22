{
  den.aspects.upower = {
    nixos = {pkgs, ...}: {
      services.upower = {
        enable = true;
        usePercentageForPolicy = true;
        percentageLow = 15;
        percentageCritical = 8;
        percentageAction = 5;
        criticalPowerAction = "Hibernate";
      };
      environment.systemPackages = [pkgs.upower];
    };
  };
}
