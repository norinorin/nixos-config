{
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 12 * 1024; # FIXME: match it with RAM size
    }
  ];

  # FIXME: get offset from `sudo filefrag -v /var/lib/swapfile | awk '/^[ ]*[0-9]+:/{print $4; exit}' | cut -d'.' -f1`
  boot.kernelParams = ["resume_offset=75100160"];
  # FIXME: get the uuid from `lsblk -f`
  boot.resumeDevice = "/dev/disk/by-uuid/93d0ed76-31cb-4867-84bc-e06d273aa01c";
  powerManagement.enable = true;
  services.logind.settings.Login = {
    HandlePowerKey = "hibernate";
    HandlePowerKeyLongPress = "poweroff";
  };
}
