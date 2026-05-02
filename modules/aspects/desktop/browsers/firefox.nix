{den, ...}: {
  den.aspects.firefox = {
    includes = [den.aspects.theme];

    homeManager = {
      pkgs,
      config,
      ...
    }: let
      lock-false = {
        Value = false;
        Status = "locked";
      };
      lock-true = {
        Value = true;
        Status = "locked";
      };
      sharedSearchEngines = {
        nix-packages = {
          name = "Nix Packages";
          urls = [
            {
              template = "https://search.nixos.org/packages";
              params = [
                {
                  name = "type";
                  value = "packages";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }
          ];

          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = ["@np"];
        };
        nixos-wiki = {
          name = "NixOS Wiki";
          urls = [{template = "https://wiki.nixos.org/w/index.php?search={searchTerms}";}];
          iconMapObj."16" = "https://wiki.nixos.org/favicon.ico";
          definedAliases = ["@nw"];
        };
      };
      firefoxProfileLauncher = name: {
        name = "firefox-${name}.desktop";
        value = {
          type = "Application";
          name = "Firefox (${name})";
          exec = "firefox --name firefox-${name} -P ${name}";
          terminal = false;
          categories = ["Network" "WebBrowser"];
          icon = "firefox";
        };
      };
      parfait = pkgs.stdenv.mkDerivation rec {
        pname = "parfait-firefox-theme";
        version = "0.14";

        src = pkgs.fetchFromGitHub {
          owner = "reizumii";
          repo = "parfait";
          rev = "v${version}";
          sha256 = "sha256-vdI5VYlUa1XiVyirkN0TryiDHy9PHmB26FD6mWFs+JU=";
        };

        installPhase = ''
          mkdir -p $out
          cp -r parfait $out/
        '';
      };
      parfaitSettings = {
        "layout.css.prefers-color-scheme.content-override" = 2; # 0 dark, 1 light, 2 system
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-properties.content.enabled" = true;
        "parfait.urlbar.url.center" = true;
        "parfait.urlbar.search-mode.glow" = true;
      };
      # FIXME: adjust colours in private mode
      getCss = bgColour: textColour: {
        userChrome = ''
          @import "${parfait}/parfait/parfait.css";

          :root {
            --toolbox-bgcolor: ${bgColour} !important;
            --toolbox-bgcolor-inactive: var(--toolbox-bgcolor) !important;
            --pf-textcolor: ${textColour} !important;
          }
        '';
        userContent = ''
          @import "${parfait}/parfait/pages.css";

          :root {
            --newtab-background-color: ${bgColour} !important;
            /* no need to set !important here */
            color: ${textColour};
          }
        '';
      };
    in {
      programs.firefox = {
        enable = true;
        profiles = {
          default =
            {
              settings = parfaitSettings;
              extensions.force = true; # stylix shenanigans
              search = {
                force = true;
                engines =
                  sharedSearchEngines
                  // {
                    youtube = {
                      name = "YouTube";
                      urls = [{template = "https://www.youtube.com/results?search_query={searchTerms}";}];
                      definedAliases = ["@yt" "www.youtube.com" "youtube.com"];
                    };
                    anilist = {
                      name = "AniList";
                      urls = [{template = "https://anilist.co/search/anime?search={searchTerms}";}];
                      definedAliases = ["@al" "anilist.co"];
                    };
                    myanimelist = {
                      name = "MyAnimeList";
                      urls = [{template = "https://myanimelist.net/search/all?q={searchTerms}&cat=all";}];
                      definedAliases = ["@mal" "myanimelist.net"];
                    };
                    mydramalist = {
                      name = "MyDramaList";
                      urls = [{template = "https://mydramalist.com/search?q={searchTerms}";}];
                      definedAliases = ["@mdl" "mydramalist.com"];
                    };
                    jisho = {
                      name = "Jisho";
                      urls = [{template = "https://jisho.org/search/{searchTerms}";}];
                      definedAliases = ["@jd" "jisho.org"];
                    };
                  };
              };
            }
            // getCss
            "${config.lib.stylix.colors.withHashtag.base00}5F"
            "${config.lib.stylix.colors.withHashtag.base05}";
          school =
            {
              id = 1;
              settings =
                parfaitSettings
                // {
                  # force opposite polarity
                  "ui.systemUsesDarkTheme" =
                    if config.stylix.polarity == "dark"
                    then 0
                    else 1;
                };
              extensions.force = true; # stylix shenanigans
              search = {
                force = true;
                engines = sharedSearchEngines;
              };
            }
            // getCss
            "${config.lib.stylix.colors.withHashtag.base07}5F"
            "${config.lib.stylix.colors.withHashtag.base00}";
        };
        policies = {
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
          };
          DisablePocket = true;
          DisableFirefoxAccounts = true;
          DisableAccounts = true;
          DisableFirefoxScreenshots = true;
          OverrideFirstRunPage = "";
          OverridePostUpdatePage = "";
          DontCheckDefaultBrowser = true;
          DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
          DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
          SearchBar = "unified"; # alternative: "separate"

          ExtensionSettings = {
            "*".installation_mode = "blocked";
            "uBlock0@raymondhill.net" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "force_installed";
            };

            "zotero@chnm.gmu.edu" = {
              install_url = "https://www.zotero.org/download/connector/dl?browser=firefox&version=5.0.189";
              installation_mode = "force_installed";
            };

            "{c84d89d9-a826-4015-957b-affebd9eb603}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/file/4617271/mal_sync-0.12.2.xpi";
              installation_mode = "force_installed";
            };
          };

          Preferences = {
            "browser.contentblocking.category" = {
              Value = "strict";
              Status = "locked";
            };
            "extensions.pocket.enabled" = lock-false;
            "extensions.screenshots.disabled" = lock-true;
            "browser.topsites.contile.enabled" = lock-false;
            "browser.formfill.enable" = lock-false;
            "browser.search.suggest.enabled" = lock-false;
            "browser.search.suggest.enabled.private" = lock-false;
            "browser.urlbar.suggest.searches" = lock-false;
            "browser.urlbar.showSearchSuggestionsFirst" = lock-false;
            "browser.newtabpage.activity-stream.feeds.section.topstories" = lock-false;
            "browser.newtabpage.activity-stream.feeds.snippets" = lock-false;
            "browser.newtabpage.activity-stream.section.highlights.includePocket" = lock-false;
            "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = lock-false;
            "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = lock-false;
            "browser.newtabpage.activity-stream.section.highlights.includeVisited" = lock-false;
            "browser.newtabpage.activity-stream.showSponsored" = lock-false;
            "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
            "browser.tabs.insertAfterCurrent" = lock-true;
            "browser.tabs.unloadOnLowMemory".Value = true;
            "network.trr.mode" = {
              Value = 3;
              Status = "default";
              Type = "Number";
            };
            "network.trr.url" = {
              Value = "https://mozilla.cloudflare-dns.com/dns-query";
              Status = "default";
            };
            "layout.css.devPixelsPerPx" = {
              Value = "0.75";
              Status = "locked";
            };
            "sidebar.revamp" = lock-true;
            "sidebar.verticalTabs" = lock-true;
          };
        };
      };

      stylix.targets.firefox = {
        enable = false;
        colorTheme.enable = false;
        profileNames = ["default" "school"];
      };

      xdg.desktopEntries = builtins.listToAttrs (
        map firefoxProfileLauncher (builtins.attrNames config.programs.firefox.profiles)
      );
    };
  };
}
