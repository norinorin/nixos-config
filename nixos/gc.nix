{
  boot.loader.systemd-boot.configurationLimit = 10;
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = ["weekly"];
  };
}
