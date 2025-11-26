{
  swapDevices = [
    {
      # FIXME
      device = "/var/lib/swapfile";
      size = 12 * 1024; # match it with RAM size
    }
  ];

  boot.kernelParams = ["resume_offset=75100160"];
  boot.resumeDevice = "/dev/disk/by-uuid/93d0ed76-31cb-4867-84bc-e06d273aa01c";
  powerManagement.enable = true;
  services.logind.powerKey = "hibernate";
  services.logind.powerKeyLongPress = "poweroff";
}
