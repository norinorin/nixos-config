{
  den.aspects.audio = {
    nixos = {pkgs, ...}: {
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
          "10-mono" = {
            "context.modules" = [
              {
                name = "libpipewire-module-loopback";
                args = {
                  "node.description" = "Mono Playback Device";
                  "capture.props" = {
                    "node.name" = "mono_output";
                    "media.class" = "Audio/Sink";
                    "audio.position" = ["MONO"];
                  };
                  "playback.props" = {
                    "node.name" = "playback.mono_output";
                    "audio.position" = ["MONO"];
                    "node.passive" = true;
                  };
                };
              }
            ];
          };

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

          "20-parametric-eq" = {
            "context.modules" = let
              eqFilters = pkgs.writeText "parametric-eq.txt" ''
                Preamp: -1.6 dB
                Filter 1: ON PK Fc 20 Hz Gain -1.8 dB Q 1.900
                Filter 2: ON PK Fc 40 Hz Gain -6.1 dB Q 0.500
                Filter 3: ON PK Fc 44 Hz Gain 0.9 dB Q 1.700
                Filter 4: ON PK Fc 160 Hz Gain -0.5 dB Q 0.900
                Filter 5: ON PK Fc 510 Hz Gain 2.0 dB Q 1.000
                Filter 6: ON PK Fc 1500 Hz Gain -2.2 dB Q 1.000
                Filter 7: ON PK Fc 3000 Hz Gain 2.0 dB Q 2.000
                Filter 8: ON PK Fc 4600 Hz Gain -2.5 dB Q 2.000
                Filter 9: ON PK Fc 6000 Hz Gain 2.5 dB Q 2.000
                Filter 10: OFF PK Fc 0 Hz Gain 0.0 dB Q 0.000
              '';
            in [
              {
                name = "libpipewire-module-parametric-equalizer";
                args = {
                  "equalizer.filepath" = eqFilters;
                  "equalizer.description" = "DF Target Parametric EQ";
                  "audio.channels" = 2;
                  "audio.position" = ["FL" "FR"];
                };
              }
            ];
          };
        };
      };

      # give chromium-based browsers access to JA11
      # https://www.reddit.com/r/FiiO/comments/1o8c4tg/fix_fiio_dac_not_controllable_via_chrome_on_linux/
      services.udev.extraRules = ''
        ATTRS{idVendor}=="2972", ATTRS{idProduct}=="0102", MODE="0660", GROUP="users"
      '';

      security.rtkit.enable = true;
    };

    nixosOtg = {lib, ...}: {
      services.pipewire = {
        extraConfig.pipewire = {
          "91-resample-quality" = {
            "stream.properties" = {
              "resample.quality" = lib.mkForce 6;
            };
          };
        };
      };
    };

    provides.denoiser = {
      nixos = {pkgs, ...}: {
        services.pipewire.extraConfig.pipewire = {
          "99-input-denoising" = {
            "context.modules" = [
              {
                name = "libpipewire-module-filter-chain";
                args = {
                  "node.description" = "Noise Canceling source";
                  "media.name" = "Noise Canceling source";
                  "filter.graph" = {
                    nodes = [
                      {
                        type = "ladspa";
                        name = "rnnoise";
                        plugin = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
                        label = "noise_suppressor_mono";
                        control = {
                          "VAD Threshold (%)" = 50.0;
                          "VAD Grace Period (ms)" = 300;
                          "Retroactive VAD Grace (ms)" = 4;
                        };
                      }
                    ];
                  };
                  "capture.props" = {
                    "node.name" = "capture.rnnoise_source";
                    "node.passive" = true;
                    "audio.rate" = 48000;
                    "audio.channels" = 1;
                    "audio.position" = ["MONO"];
                  };
                  "playback.props" = {
                    "node.name" = "rnnoise_source";
                    "media.class" = "Audio/Source";
                    "audio.rate" = 48000;
                    "audio.channels" = 1;
                    "audio.position" = ["MONO"];
                  };
                };
              }
            ];
          };
        };
      };
    };
  };
}
