{
  pkgs,
  inputs,
  ...
}: let
  sddm-theme = let
    wallpaper = pkgs.runCommand "login-screen.jpg" {} ''
      cp ${../home/wallpapers/pitvice-lake.jpg} $out
    '';
  in
    inputs.silentSDDM.packages.${pkgs.system}.default.override {
      theme-overrides = {
        LockScreen = {
          background = "login-screen.jpg";
          blur = 0;
          brightness = -0.03;
        };
        LoginScreen = {
          background = "login-screen.jpg";
          blur = 60;
          brightness = -0.1;
        };
      };
      extraBackgrounds = [wallpaper];
    };
in {
  environment.systemPackages = [sddm-theme sddm-theme.test];
  qt.enable = true;
  services.displayManager.sddm = {
    package = pkgs.kdePackages.sddm;
    enable = true;
    wayland.enable = true;
    theme = sddm-theme.pname;
    extraPackages = sddm-theme.propagatedBuildInputs;
    settings = {
      General = {
        GreeterEnvironment = "QML2_IMPORT_PATH=${sddm-theme}/share/sddm/themes/${sddm-theme.pname}/components/,QT_IM_MODULE=qtvirtualkeyboard";
        InputMethod = "qtvirtualkeyboard";
      };
    };
  };
}
