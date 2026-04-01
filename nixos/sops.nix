{
  pkgs,
  inputs,
  config,
  ...
}: {
  imports = [inputs.sops-nix.nixosModules.sops];

  environment.systemPackages = [pkgs.sops];

  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  sops.age.generateKey = true;

  sops.secrets."openweather/key" = {owner = config.users.users.nori.name;};
  sops.secrets."openweather/lat" = {owner = config.users.users.nori.name;};
  sops.secrets."openweather/lon" = {owner = config.users.users.nori.name;};
}
