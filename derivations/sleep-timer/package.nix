{
  stdenv,
  makeWrapper,
  playerctl,
}:
stdenv.mkDerivation {
  pname = "sleep-timer";
  version = "0.1";

  src = ./.;

  buildInputs = [makeWrapper playerctl];

  installPhase = ''
    mkdir -p $out/bin
    cp $pname.sh $out/bin/$pname
    chmod +x $out/bin/$pname

    wrapProgram $out/bin/$pname --prefix PATH : ${playerctl}/bin
  '';
}
