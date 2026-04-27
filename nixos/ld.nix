{pkgs, ...}: {
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc # Provides libstdc++.so.6 and libgcc_s.so.1
      glibc # Provides libc.so.6, libm.so.6, libdl.so.2, etc.
      zlib # Almost always needed by these modules

      # These are for discord_voice.node and gpu_encoder_helper
      libpulseaudio # libpulse.so.0
      alsa-lib # libasound.so.2
      libopus # libopus.so.0
      libvorbis # libvorbis.so.0 and libvorbisenc.so.2
      flac # libFLAC.so.14
      lame # libmp3lame.so.0
      libmpg123 # libmpg123.so.0
      libogg # libogg.so.0
      wayland # libwayland-client.so.0
      libffi # libffi.so.8
      dbus # libdbus-1.so.3
      systemdLibs # libsystemd.so.0
      xorg.libX11 # libX11.so.6
      xorg.libxcb # libxcb.so.1}
    ];
  };

  environment.sessionVariables = {
    LD_LIBRARY_PATH = "/run/opengl-driver/lib";
  };
}
