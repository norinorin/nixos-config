{pkgs, ...}: let
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
in {
  programs.firefox = {
    enable = true;
    profiles = {
      default = {
        extensions.force = true; # stylix shenanigans
        search.engines =
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
      school = {
        id = 1;
        extensions.force = true; # stylix shenanigans
        search.engines = sharedSearchEngines;
      };
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
      };
    };
  };

  stylix.targets.firefox = {
    enable = true;
    colorTheme.enable = true;
    profileNames = ["default" "school"];
  };
}
