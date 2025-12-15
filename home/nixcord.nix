{
  programs.nixcord = {
    enable = true;
    discord = {
      vencord.enable = true;
    };
    vesktop.enable = false;
    equibop.enable = true;
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
        biggerStreamPreview.enable = true;
        homeTyping.enable = true;
        customIdle = {
          enable = true;
          remainInIdle = true;
        };
      };
    };
  };
}
