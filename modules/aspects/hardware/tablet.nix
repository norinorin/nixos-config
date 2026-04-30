{
  den.aspects.tablet = {
    nixos = {
      hardware.opentabletdriver.enable = true;
      hardware.uinput.enable = true;

      # https://opentabletdriver.net/Wiki/FAQ/Linux#libinput-smoothing-on-old-versions
      # docs say it's fixed but the PR is only for select distros
      environment.etc."libinput/local-overrides.quirks".text = ''
        [OpenTabletDriver Virtual Tablets]
        MatchName=OpenTabletDriver*
        AttrTabletSmoothing=0
      '';
    };
  };
}
