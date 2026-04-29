{
  den.aspects.dunst = {
    # includes = [den.aspects.theme];

    homeManager = {
      services.dunst = {
        enable = true;

        # TODO: use stylix
        configFile = ./dunstrc;
      };
    };
  };
}
