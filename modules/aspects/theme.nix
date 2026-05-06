{inputs, ...}: {
  flake-file.inputs = {
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tinted-schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };
  };

  den.aspects.theme = {
    # TODO: decide whether theme should be host-specific or shared across
    # all systems.
    nixos = {pkgs, ...}: {
      imports = [
        inputs.stylix.nixosModules.stylix
      ];

      stylix = {
        enable = true;
        base16Scheme = "${inputs.tinted-schemes}/base16/brushtrees.yaml";
        autoEnable = true;
        opacity = {
          applications = 1.;
          desktop = 0.97;
          terminal = 0.97;
          popups = 0.95;
        };
        fonts.monospace = {
          name = "Azeret Mono";
          package = pkgs.azeret-mono;
        };
        polarity = "light";

        # Desirable for single user
        homeManagerIntegration = {
          autoImport = true;
          followSystem = true;
        };
      };
    };

    homeManager = {config, ...}: {
      config = {
        lib.my.getBgColour = polarity: let
          c = config.lib.stylix.colors.withHashtag;
          dark =
            if config.stylix.polarity == "dark"
            then c.base00
            else c.base07;
          light =
            if config.stylix.polarity == "dark"
            then c.base07
            else c.base00;
        in
          if polarity == "dark"
          then dark
          else light;

        lib.my.getTextColour = polarity: let
          c = config.lib.stylix.colors.withHashtag;
          isDarkTheme = config.stylix.polarity == "dark";

          textOnDark =
            if isDarkTheme
            then c.base05
            else c.base00;
          textOnLight =
            if isDarkTheme
            then c.base00
            else c.base05;
        in
          if polarity == "dark"
          then textOnDark
          else textOnLight;

        gtk.gtk4.theme = config.gtk.theme;
      };
    };

    provides.cursor = {
      user,
      pkgs,
      lib,
      ...
    }: {
      homeManager = {
        home.pointerCursor = {
          gtk.enable = true;
          package = lib.getAttr user.cursor.pname pkgs;
          inherit (user.cursor) name size;
        };
      };
    };
  };
}
