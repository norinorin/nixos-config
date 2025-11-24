{ config, ... }: {
    imports = [
        ./shared.nix
        ../home/apps.nix
        ../home/browsers
        ../home/dev
        ../home/net
        ../home/wms
    ];

    programs.git = {
        enable = true;
        
        userName = "Norizon";
        userEmail = "norizontunes@gmail.com";
        
        signing = {
            key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
            signByDefault = true;
        };

        extraConfig.gpg = {
            format = "ssh";
        };
    };

    programs.bash = {
        enable = true;
        shellAliases = {
            rbd = "sudo nixos-rebuild switch --flake ~/dotfiles#toaster";
        };
    };
}