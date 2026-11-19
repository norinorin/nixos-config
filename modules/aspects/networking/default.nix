{
  den.aspects.networking = {
    nixos = {host}: {
      networking = {
        hostName = host.name;

        networkmanager = {
          enable = true;
          dns = "systemd-resolved";
        };

        useDHCP = false;
        dhcpcd.enable = false;
        firewall = {
          enable = true;
          allowedTCPPortRanges = [
            {
              from = 8000;
              to = 9000;
            }
          ];

          allowedTCPPorts = [
            # palworld
            25575
            # anime_rpc
            56727
            # vite
            5173
          ];
          allowedUDPPorts = [
            # palworld
            8211
          ];
        };
      };

      programs = {
        mtr.enable = true;
      };

      services = {
        resolved = {
          enable = true;
          settings.Resolve = {
            DNS = ["127.0.0.1" "::1"];
            FallbackDNS = [];
            Domains = ["~."];
            # let dnscrypt handle dnssec
            DNSSEC = "false";
          };
        };

        dnscrypt-proxy = {
          enable = true;
          settings = {
            ipv6_servers = false;
            require_dnssec = false;
            sources.public-resolvers = {
              urls = [
                "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
                "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
              ];
              cache_file = "/var/cache/dnscrypt-proxy/public-resolvers.md";
              minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
            };
            server_names = ["cloudflare" "google" "nextdns"];
          };
        };
      };
    };
  };
}
