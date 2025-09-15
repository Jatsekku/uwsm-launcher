{ pkgs, bash-logger }:

let
  uwsm-launcher-scriptContent = builtins.readFile ./uwsm-launcher.sh;
  bash-logger-scriptPath = bash-logger.passthru.scriptPath;
in
pkgs.writeShellApplication {
  name = "uwsm-launcher";
  text = ''
    #!/usr/bin/env bash
    export BASH_LOGGER_SH=${bash-logger-scriptPath}

    ${uwsm-launcher-scriptContent}
  '';
  runtimeInputs = [
    pkgs.bash
    pkgs.uwsm
  ];
}
