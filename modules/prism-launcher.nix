{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    (prismlauncher.override {
      # Add binary required by some mod
      # additionalPrograms = [ffmpeg];

      jdks = [graalvm-ce];
    })
  ];
}
