{
  den.aspects.gnupg = {
    nixos.programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}
