{
  pkgs,
  desktop,
  ...
}: {
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest.yaml";
    autoEnable = true;
    opacity =
      if desktop == "hyprland"
      then {
        applications = 0.95;
        desktop = 0.5;
        terminal = 0.6;
      }
      else {
        applications = 1.;
        desktop = 1.;
        terminal = 1.;
      };
    fonts.monospace = {
      name = "Azeret Mono";
      package = pkgs.azeret-mono;
    };
    polarity = "dark";
  };

  environment.systemPackages = [
    pkgs.bibata-cursors
  ];
}
