final: prev: {
  # hacky but works so ¯\_(ツ)_/¯
  undervolt = prev.writeShellScriptBin "undervolt" ''
    #!/usr/bin/env bash
    args="$@"
    clean_args=$(echo "$args" | sed 's/=/ /g')
    exec ${prev.undervolt}/bin/undervolt $clean_args
  '';
}
