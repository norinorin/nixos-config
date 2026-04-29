{
  den,
  lib,
  ...
}: {
  class,
  aspect-chain,
}:
den._.forward {
  each = ["nixos" "homeManager"];
  fromClass = class: "${class}Otg";
  intoClass = lib.id;
  intoPath = _: ["specialisation" "on-the-go" "configuration"];
  fromAspect = _: lib.head aspect-chain;
}
