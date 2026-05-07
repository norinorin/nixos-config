{lib, ...}: let
  specialisations = [
    "on-the-go"
    "no-undervolt"
    "x11"
  ];

  mkNixosSpecialisation = name: {
    configuration = {
      system.nixos.tags = [name];
      environment.etc."specialisation".text = name;
    };
  };

  mkHmSpecialisation = name: {
    configuration = {
      xdg.dataFile."home-manager/specialisation".text = name;
    };
  };
in {
  den.aspects.specialisations = {
    nixos.specialisation =
      lib.genAttrs specialisations mkNixosSpecialisation;

    homeManager.specialisation =
      lib.genAttrs specialisations mkHmSpecialisation;
  };
}
