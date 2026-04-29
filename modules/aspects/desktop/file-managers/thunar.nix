{den, ...}: {
  den.aspects.thunar = {
    includes = [den.aspects.mpv den.aspects.helix];

    nixos = {pkgs, ...}: {
      programs = {
        thunar = {
          enable = true;
          plugins = with pkgs.xfce; [
            thunar-archive-plugin
            thunar-volman
          ];
        };
        xfconf.enable = true;
      };

      services.gvfs.enable = true;
      services.tumbler.enable = true;
    };

    homeManager = {
      xdg.configFile."Thunar/uca.xml".text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <actions>
          <action>
            <icon>utilities-terminal</icon>
            <name>Open Terminal Here</name>
            <submenu></submenu>
            <unique-id>1740289901429308-1</unique-id>
            <command>alacritty --working-directory %f</command>
            <description>Example for a custom action</description>
            <range></range>
            <patterns>*</patterns>
            <startup-notify/>
            <directories/>
          </action>
          <action>
            <icon></icon>
            <name>Open with mpv</name>
            <submenu></submenu>
            <unique-id>1742145437893827-1</unique-id>
            <command>cd %d; mpv %n</command>
            <description>Open selected file with mpv</description>
            <range></range>
            <patterns>*</patterns>
            <video-files/>
          </action>
          <action>
            <icon>helix</icon>
            <name>Edit file in Helix</name>
            <submenu></submenu>
            <unique-id>1743083263108051-1</unique-id>
            <command>alacritty -e hx %n</command>
            <description>Edit file in Helix</description>
            <range>*</range>
            <patterns>*</patterns>
            <text-files/>
            <other-files/>
          </action>
        </actions>
      '';
      xdg.configFile."Thunar/accel.scm".text = ''
        (gtk_accel_path "<Actions>/ThunarActions/uca-action-1743083263108051-1" "e")
      '';
    };
  };
}
