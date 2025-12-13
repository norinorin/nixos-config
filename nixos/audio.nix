{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    wireplumber.extraConfig = {
      # fix no sound below a volume cutoff
      # https://wiki.archlinux.org/title/PulseAudio/Troubleshooting#No_sound_below_a_volume_cutoff_or_Clipping_on_a_particular_output_device
      "99-ignore-db" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              {"device.name" = "~alsa_card.*";}
            ];
            actions = {
              update-props = {
                "api.alsa.ignore-dB" = true;
              };
            };
          }
        ];
      };
    };

    extraConfig.pipewire = {
      "91-resample-quality" = {
        "stream.properties" = {
          "resample.quality" = 10;
        };
      };

      "10-rates" = {
        "context.properties" = {
          "default.clock.allowed-rates" = [44100 48000 88200 96000];
        };
      };
    };
  };
}
