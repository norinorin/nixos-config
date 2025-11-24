{ lib, ... }:
{
    boot.kernelModules = [ "msr" ];
    
    services.undervolt = {
        enable = true;
        coreOffset = -95;
        uncoreOffset = -95;
        turbo = 1;
        temp = -3;
        p1 = {
            limit = 95;
            window = 56;
        };
        p2 = {
            limit = 162;
            window = 0.002;
        };
    };

    specialisation.on-the-go.configuration = {
        system.nixos.tags = [ "on-the-go" ];
        services.undervolt = {
            turbo = lib.mkForce 0;
            temp = lib.mkForce (-15);
            p1.limit = lib.mkForce 45;
            p2.limit = lib.mkForce 45;
        };
    };
}