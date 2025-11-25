{ pkgs, ... }: {
    home.packages = with pkgs; [
        alacritty
        qbittorrent
        audacity
    ];

    programs.nixcord = {
        enable = true;
        discord = {
            vencord.enable = true;
        };
        vesktop.enable = false;
        equibop.enable = false;
        dorion.enable = false;
        config = {
            frameless = true;
            plugins = {
                alwaysTrust.enable = true;
                anonymiseFileNames.enable = true;
                # betterAudioPlayer.enable = true;
                disableCallIdle.enable = true;
                experiments.enable = true;
                fakeNitro = {
                    enable = true;
                    enableEmojiBypass = false;
                    enableStickerBypass = false;
                    enableStreamQualityBypass = true;
                };
                fixSpotifyEmbeds.enable = true;
                fixYoutubeEmbeds.enable = true;
                gameActivityToggle.enable = true;
                messageLatency.enable = true;
                messageLogger.enable = true;
                relationshipNotifier.enable = true;
                silentTyping.enable = true;
                platformIndicators = {
                    enable = true;
                    showBots = true;
                };
            };
        };
    };

    programs.obs-studio = {
        enable = true;
        package = (
            pkgs.obs-studio.override {
                cudaSupport = true;
            }
        );
        plugins = with pkgs.obs-studio-plugins; [
            wlrobs
            obs-backgroundremoval
            obs-pipewire-audio-capture
            obs-gstreamer
            obs-vkcapture
        ];
    };

    programs.mpv = {
        enable = true;

        package = (
            pkgs.mpv-unwrapped.wrapper {
                scripts = with pkgs.mpvScripts; [
                    uosc
                    sponsorblock
                    thumbfast
                ];

                mpv = pkgs.mpv-unwrapped.override {
                    waylandSupport = true;
                    ffmpeg = pkgs.ffmpeg-full;
                };
            }
        );

        config = {
            profile = "high-quality";
            ytdl-format = "bestvideo+bestaudio";
            cache-default = 4000000;
        };
    };
}