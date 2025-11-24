{ config, ... }: {
    imports = [
        ./shared.nix
        ../home/apps.nix
        ../home/bars
        ../home/browsers
        ../home/dev
        ../home/net
        ../home/wms
        ../home/misc
        ../home/wallpapers
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
            killall = "function _killall(){ ps aux | grep \"[ ]\$1\" | awk '{print \$2}' | xargs kill; }; _killall";
        };
    };

    services.playerctld.enable = true;
}