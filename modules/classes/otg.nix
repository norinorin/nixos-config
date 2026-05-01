# Forwards `nixosOtg` and `homeManagerOtg` to `nixos` and `homeManager`'s
# `.specialisation.on-the-go.configuration` respectively
{
  den,
  lib,
  ...
}: {
  den.ctx.user.includes = [
    (
      {host, ...}: {
        class,
        aspect-chain,
      }:
        den._.forward {
          each = ["nixos" "homeManager"];
          fromClass = class: "${class}Otg";
          intoClass = lib.id;
          intoPath = _: ["specialisation" "on-the-go" "configuration"];
          fromAspect = _: lib.head aspect-chain;
          guard = {...}: _: lib.mkIf (host.isMobile or false);
        }
    )
  ];
}
