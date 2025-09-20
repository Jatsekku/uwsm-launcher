{
  self,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.uwsm-launcher;
  uwsm-launcher = self.packages.${pkgs.system}.default;
in
{
  options.services.uwsm-launcher = {
    enable = lib.mkEnableOption "Enable UWSM launcher";

    username = lib.mkOption {
      type = lib.types.str;
      description = "Name of user used to run compositor";
    };

    compositor-name = lib.mkOption {
      type = lib.types.str;
      description = "Name of managed compositor";
    };

    compositor-launcher = lib.mkOption {
      type = lib.types.str;
      description = "Compositor launcher command";
    };

    exe-start = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
    };

    exe-stop = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services."uwsm-launcher" = {
      description = "Start ${cfg.compositor-name} compositor via uwsm-launcher";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        User = cfg.username;
        ExecStart = "${lib.getExe uwsm-launcher} start ${cfg.username} ${cfg.compositor-name} ${cfg.compositor-launcher}";
        ExecStop = "${lib.getExe uwsm-launcher} stop  ${cfg.username} ${cfg.compositor-name}";
      };
    };

    services.uwsm-launcher.exe-start = "systemctl start uwsm-launcher.service";
    services.uwsm-launcher.exe-stop = "systemctl stop uwsm-launcher.service";
  };
}
