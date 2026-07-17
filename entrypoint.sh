#!/bin/bash
set -euo pipefail

ROS_DISTRO="${ROS_DISTRO:-jazzy}"
COLCON_WORKSPACE="${COLCON_WORKSPACE:-colcon_ws}"

USER_NAME="${USER_NAME:-${DISTRIBUTION_USER:-ros}}"
USER_ID="${USER_ID:-1000}"
GROUP_ID="${GROUP_ID:-1000}"

create_user_if_needed() {
    local name="$1"
    local uid="$2"
    local gid="$3"

    if id -u "$name" >/dev/null 2>&1; then
        return 0
    fi

    if getent group "$name" >/dev/null 2>&1; then
        groupadd -g "$gid" "$name" 2>/dev/null || true
    else
        groupadd -g "$gid" "$name" 2>/dev/null || true
    fi

    useradd -m -u "$uid" -g "$gid" -s /bin/bash "$name" 2>/dev/null || \
        useradd -m -s /bin/bash "$name"
}

if [ "$(id -u)" -eq 0 ]; then
    create_user_if_needed "$USER_NAME" "$USER_ID" "$GROUP_ID"

    mkdir -p "/home/$USER_NAME"
    chown -R "$USER_NAME:$USER_NAME" "/home/$USER_NAME" "/opt/${COLCON_WORKSPACE}" 2>/dev/null || true

    export HOME="/home/$USER_NAME"
    export USER="$USER_NAME"
    export LOGNAME="$USER_NAME"

    su - "$USER_NAME" -c "/usr/local/bin/init.sh"
    exec su - "$USER_NAME" -c "cd \"$HOME\" && exec /bin/bash -l"
fi

/usr/local/bin/init.sh

if [ $# -gt 0 ]; then
    exec "$@"
fi

exec /bin/bash -l