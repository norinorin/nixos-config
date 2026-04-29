{
  den.aspects.networking = {
    nixos = {
      networking = {
        networkmanager = {
          enable = true;
          dns = "none";
        };
        useDHCP = false;
        dhcpcd.enable = false;
        nameservers = [
          "127.0.0.1"
          "::1"
        ];
        firewall = {
          enable = true;
          allowedTCPPortRanges = [
            {
              from = 8000;
              to = 9000;
            }
          ];

          # Palworld
          allowedTCPPorts = [25575];
          allowedUDPPorts = [8211];
        };
      };

      programs = {
        mtr.enable = true;
      };

      services = {
        dnscrypt-proxy = {
          enable = true;
          settings = {
            ipv6_servers = true;
            require_dnssec = true;
            sources.public-resolvers = {
              urls = [
                "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
                "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
              ];
              cache_file = "/var/cache/dnscrypt-proxy/public-resolvers.md";
              minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
            };
            server_names = ["cloudflare" "google"];
          };
        };
      };
    };

    provides.to-users = {user, ...}: {
      nixos.users.users."${user.userName}".extraGroups = ["networkmanager"];
    };
  };
}
