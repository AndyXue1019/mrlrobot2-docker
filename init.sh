#!/bin/bash
set -eo pipefail

ROS_DISTRO="${ROS_DISTRO:-jazzy}"
COLCON_WORKSPACE="${COLCON_WORKSPACE:-colcon_ws}"
LOCK_FILE="$HOME/.ros_init_done"

if [ "${1:-}" != "--force" ] && [ -f "$LOCK_FILE" ]; then
    return 0 2>/dev/null || exit 0
fi

append_if_missing() {
    local line="$1"
    local file="${2:-$HOME/.bashrc}"

    grep -Fqx "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

if [ -f "/opt/ros/${ROS_DISTRO}/setup.bash" ]; then
    source "/opt/ros/${ROS_DISTRO}/setup.bash"
fi

WORKSPACE_ROOT="$HOME/${COLCON_WORKSPACE}"

if [ ! -d "$WORKSPACE_ROOT" ]; then
    echo "Copying colcon workspace..."
    cp -a "/opt/$COLCON_WORKSPACE" "$HOME/"
fi

if [ -d "$WORKSPACE_ROOT/src" ]; then
    echo "Installing ROS dependencies..."
    cd "$WORKSPACE_ROOT/src"
    sudo rosdep init >/dev/null 2>&1 || true
    rosdep update >/dev/null 2>&1 || true
    rosdep install --from-paths ./ --ignore-src -r -y
fi

if [ -d "$WORKSPACE_ROOT" ]; then
    echo "Building code..."
    cd "$WORKSPACE_ROOT"
    colcon build --symlink-install >/dev/null 2>&1 || true
fi

echo "Adding Environment Variables..."
append_if_missing "" "$HOME/.bashrc"

append_if_missing "alias eb='vim ~/.bashrc'" "$HOME/.bashrc"
append_if_missing "alias nb='nano ~/.bashrc'" "$HOME/.bashrc"
append_if_missing "alias sb='source ~/.bashrc'" "$HOME/.bashrc"

append_if_missing "alias cw='cd ~/${COLCON_WORKSPACE}'" "$HOME/.bashrc"
append_if_missing "alias cs='cd ~/${COLCON_WORKSPACE}/src'" "$HOME/.bashrc"
append_if_missing "alias cb='cd ~/${COLCON_WORKSPACE} && colcon build --symlink-install && source ~/.bashrc'" "$HOME/.bashrc"

append_if_missing "source /opt/ros/${ROS_DISTRO}/setup.bash" "$HOME/.bashrc"
append_if_missing "source $HOME/${COLCON_WORKSPACE}/install/setup.bash" "$HOME/.bashrc"
append_if_missing "export ROS_DOMAIN_ID=30 # 0~101" "$HOME/.bashrc"

touch "$LOCK_FILE"
echo "Complete."
echo "Please restart the terminal."
