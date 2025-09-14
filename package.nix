{ pkgs, bash-logger }:

let
  uwsm-launcher-script = builtins.readFile ./uwsm-launcher.sh;
in
pkgs.writeShellApplication {
  name = "uwsm-launcher";
  text = uwsm-launcher-script;
  runtimeInputs = [
    bash-logger
    pkgs.bash
    pkgs.uwsm
  ];
}
