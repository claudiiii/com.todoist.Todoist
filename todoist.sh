#!/bin/bash

set -oue pipefail

EXTRA_ARGS=()

add_argument() {
    declare -i "$1"=${!1:-0}

    if [[ "${!1}" -eq 1 ]]; then
        EXTRA_ARGS+=(${@:2})
    fi
}

# Nvidia GPUs may need to disable GPU acceleration:
# flatpak override --user --env=TODOIST_DISABLE_GPU=1 com.todoist.Todoist
add_argument TODOIST_DISABLE_GPU --disable-gpu
add_argument TODOIST_ENABLE_AUTOSCROLL --enable-blink-features=MiddleClickAutoscroll

# Wayland support can be optionally enabled like so:
# flatpak override --user --socket=wayland com.todoist.Todoist

WL_DISPLAY="${WAYLAND_DISPLAY:-"wayland-0"}"
# Some compositors a real path a instead of a symlink for WAYLAND_DISPLAY:
# https://github.com/flathub/md.obsidian.Obsidian/issues/284
if [[ -e "${XDG_RUNTIME_DIR}/${WL_DISPLAY}" || -e "/${WL_DISPLAY}" ]]; then
    echo "Debug: Enabling Wayland backend"
    EXTRA_ARGS+=(
        --ozone-platform-hint=auto
        --enable-features=WaylandWindowDecorations
        --enable-wayland-ime
    )
fi

echo "Debug: Will run Todoist with the following arguments: ${EXTRA_ARGS[@]}"
echo "Debug: Additionally, user gave: $@"

export FLATPAK_ID="${FLATPAK_ID:-com.todoist.Todoist}"
export TMPDIR="${XDG_RUNTIME_DIR}/app/${FLATPAK_ID}"

zypak-wrapper /app/todoist $@ ${EXTRA_ARGS[@]}
