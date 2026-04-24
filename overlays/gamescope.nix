# I don't want to override it in multiple places
final: prev: {
  gamescope = prev.gamescope.overrideAttrs (old: {
    NIX_CFLAGS_COMPILE =
      (old.NIX_CFLAGS_COMPILE or []) ++ ["-fno-fast-math"];
  });
}
