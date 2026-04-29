{
  den,
  lib,
  ...
}: {
  den.aspects.ssh = {
    nixos = {
      services.openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = true;
          Macs = [
            "hmac-sha2-512-etm@openssh.com"
            "hmac-sha2-256-etm@openssh.com"
            "umac-128-etm@openssh.com"

            # Samsung MyFiles
            "hmac-sha1"
            "hmac-sha2-256"
            "hmac-md5"
          ];
        };
        extraConfig = ''
          # Samsung MyFiles
          HostKeyAlgorithms +ssh-rsa
          PubkeyAcceptedAlgorithms +ssh-rsa
        '';
      };
    };

    nixosOtg = {
      services.openssh.enable = lib.mkForce false;
    };
  };
}
