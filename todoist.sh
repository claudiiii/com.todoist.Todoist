#!/bin/bash

FLAGS=''

if [[ $XDG_SESSION_TYPE == "wayland" ]] && [ -c /dev/nvidia0 ]
then
    FLAGS="$FLAGS --disable-gpu-sandbox"
fi

env TMPDIR="$XDG_RUNTIME_DIR/app/$FLATPAK_ID" zypak-wrapper /app/extra/todoist/todoist $FLAGS "$@"