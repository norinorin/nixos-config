{
  pkgs,
  config,
  lib,
}: {
  variant,
  conditionEnv ? null,
  BindsTo ? ["graphical-session.target"],
  After ? ["graphical-session.target"],
  WantedBy ? ["graphical-session.target"],
}: let
  waybarConfig = "${config.xdg.configHome}/waybar/presets/${variant}";
in {
  Unit =
    {
      Description = "Waybar for ${variant}";
      BindsTo = BindsTo;
      After = After;
    }
    // lib.optionalAttrs (conditionEnv != null) {
      ConditionEnvironment = conditionEnv;
    };

  Service = {
    ExecStart = "${pkgs.waybar}/bin/waybar -c ${waybarConfig}/config.jsonc -s ${waybarConfig}/style.css";
    Restart = "on-failure";
    RestartSec = "5s";
  };

  Install.WantedBy = WantedBy;
}
