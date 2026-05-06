{
  den.aspects.dev = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        lazygit
        gitingest
        uv
        (python3.withPackages (python-pkgs:
          with python-pkgs; [
            pandas
            requests
          ]))
        (lib.lowPrio python311)
      ];
    };
  };
}
