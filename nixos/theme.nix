{
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.stylix.nixosModules.stylix];
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest.yaml";
    autoEnable = true;
    opacity = {
      applications = 1.;
      desktop = 0.9;
      terminal = 0.9;
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
