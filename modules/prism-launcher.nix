{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    (prismlauncher.override {
      additionalLibs = [libvlc];
      additionalPrograms = [ffmpeg];
      jdks = [graalvmPackages.graalvm-ce graalvmPackages.graalvm-oracle_17];
    })
  ];
}
