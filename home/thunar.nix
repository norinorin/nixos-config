{
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
        <icon>vim</icon>
        <name>Edit file in vim</name>
        <submenu></submenu>
        <unique-id>1743083263108051-1</unique-id>
        <command>alacritty -e vim %n</command>
        <description>Edit file in vim</description>
        <range>*</range>
        <patterns>*</patterns>
        <text-files/>
      </action>
    </actions>
  '';
}
