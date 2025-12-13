{
  # fix no sound below a volume cutoff
  # https://wiki.archlinux.org/title/PulseAudio/Troubleshooting#No_sound_below_a_volume_cutoff_or_Clipping_on_a_particular_output_device
  services.pipewire.wireplumber.extraConfig = {
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

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
