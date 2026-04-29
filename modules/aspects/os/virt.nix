{
  den.aspects.virt = {
    nixos = {
      virtualisation.docker = {
        enable = true;
        daemon.settings = {
          dns = ["1.1.1.1" "8.8.8.8"];
        };
      };
    };

    provides.to-users = {user, ...}: {
      nixos.users.users."${user.userName}".extraGroups = ["docker" "kvm"];
    };
  };
}
