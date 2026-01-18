final: prev: {
  obsidian = prev.obsidian.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [final.makeWrapper];

    postFixup =
      (old.postFixup or "")
      + ''
        wrapProgram $out/bin/obsidian \
          --set SSH_ASKPASS "${final.seahorse}/libexec/seahorse/ssh-askpass" \
          --set SSH_ASKPASS_REQUIRE "force" \
          --set GIT_ASKPASS "${final.seahorse}/libexec/seahorse/ssh-askpass"
      '';
  });
}
