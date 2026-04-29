{
  den.aspects.serve_media = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        (writeShellScriptBin "serve_media" ''
          export PYTHONUNBUFFERED=1
          exec ${python3}/bin/python3 ${./serve_media.py} "$@"
        '')
      ];
    };
  };
}
