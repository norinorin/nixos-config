{
  stdenv,
  python3,
  makeWrapper,
}:
stdenv.mkDerivation {
  pname = "serve_media";
  version = "1.0";

  src = ./.;

  buildInputs = [python3 makeWrapper];

  installPhase = ''
    mkdir -p $out/bin
    cp ${./serve_media.py} $out/bin/serve_media
    chmod +x $out/bin/serve_media
    wrapProgram $out/bin/serve_media \
      --prefix PATH : "${python3}/bin" \
      --set PYTHONUNBUFFERED 1 \
  '';
}
