{
  den.aspects.impure = {
    nixos = {
      nix.settings.experimental-features = ["impure-derivations"];
    };
  };
}
