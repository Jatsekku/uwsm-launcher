#!/bin/bash
set +o errexit

# Source logger module
# shellcheck disable=SC1090,SC1091
source "${BASH_LOGGER_SH}"
logger_register_module "uwsm-launcher" "$LOG_LEVEL_DBG"
logger_set_log_file "$HOME/.local/state/uwsm-launcher/uwsm-launcher.log"

__is_compositor_running_for_user() {
    local -r username="$1"
    local -r compositor_name="$2"

    pgrep -u "$username" "$compositor_name" > /dev/null 2>&1
}

_run_command_in_systemd_context() {
    local -r command="$1"

    uid=$(id -u "$USER")
    output=$(
        bash -c "
            source /etc/profile

            export DISPLAY=:0
            export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${uid}/bus
            export XDG_RUNTIME_DIR=/run/user/${uid}

            $command
        " 2>&1
    )

    echo "$output"
}

start_compositor_as_user() {
    local -r username="$1"
    local -r compositor_name="$2"
    local -r compositor_launcher="$3"

    if __is_compositor_running_for_user "$username" "$compositor_name"; then
        log_wrn "Compositor [$compositor_name] is already running for user [$username]"
        return 1
    fi

    log_inf "Starting $compositor_name as user $username..."
    local -r command="uwsm start $compositor_launcher"
    output=$(_run_command_in_systemd_context "$command")
    log_dbg "Launcher response:"$'\n'"$output"
}

stop_compositor_as_user() {
    local -r username="$1"
    local -r compositor_name="$2"

    log_inf "Stoping $compositor_name as user $username..."
    local -r command="uwsm stop"
    output=$(_run_command_in_systemd_context "$command")
    log_dbg "Launcher response:"$'\n'"$output"
}

main() {
    local -r command="$1"
    shift

    case $command in 
        start) start_compositor_as_user "$@" ;;
        stop) stop_compositor_as_user "$@" ;;
        *) log_err "Invalid use" ;;
    esac
}

main "$@"

