{
  den.aspects.hotspot = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        linux-wifi-hotspot
        haveged
      ];
    };
  };
}
