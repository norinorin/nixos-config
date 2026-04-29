{
  den.aspects.input = {
    nixos = {
      services = {
        libinput.enable = true;
        ratbagd.enable = true;
        udisks2.enable = true;
      };
    };
  };
}
