{
  den,
  lib,
  ...
}: {host}: {
  class,
  aspect-chain,
}:
den._.forward {
  each = lib.attrValues host.users;
  fromClass = _: "users";
  intoClass = _: host.class;
  intoPath = user: ["users" "users" user.userName];
  fromAspect = _: lib.head aspect-chain;
}
