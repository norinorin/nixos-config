{
  pkgs,
  config,
  lib,
}: {
  variant,
  conditionEnv ? null,
}: let
  waybarConfig = "${config.xdg.configHome}/waybar/presets/${variant}";
in {
  Unit = {
    Description = "Waybar for ${variant}";
    PartOf = ["graphical-session.target"];
    After = ["graphical-session.target"];
    ConditionEnvironment = conditionEnv;
  };

  Service = {
    ExecStart = "${pkgs.waybar}/bin/waybar -c ${waybarConfig}/config.jsonc -s ${waybarConfig}/style.css";
    Restart = "on-failure";
    RestartSec = "5s";
  };

  Install.WantedBy = ["graphical-session.target"];
}
