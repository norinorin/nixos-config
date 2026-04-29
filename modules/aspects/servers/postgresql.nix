{
  lib,
  den,
  ...
}: {
  den.aspects.postgresql.provides.nori = {
    nixos = {pkgs, ...}: {
      services = {
        postgresql = {
          enable = true;
          ensureDatabases = ["maimai-tracker"];
          authentication = pkgs.lib.mkOverride 10 ''
            #type database  DBuser  auth-method
            local all       all     trust
          '';
        };
      };
    };

    nixosOtg = {
      services.postgresql.enable = lib.mkForce false;
    };
  };
}
