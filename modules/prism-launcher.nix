{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    (prismlauncher.override {
      additionalLibs = [libvlc];
      additionalPrograms = [ffmpeg];
      jdks = [graalvm-ce graalvmPackages.graalvm-oracle_17];
    })
  ];
}
