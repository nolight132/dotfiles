#!/bin/bash

PLUGINS=(
  "https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm|$HOME/.config/zellij/plugins/zjstatus.wasm"
)

for item in "${PLUGINS[@]}"; do
    URL="${item%|*}"
    DEST="${item#*|}"

    if [ ! -f "$DEST" ]; then
        mkdir -p "$(dirname "$DEST")"
        curl -L "$URL" -o "$DEST"
        if [ $? -ne 0 ]; then
            echo "Failed to download $URL"
        else
            echo "Installed $(basename "$DEST") to $DEST"
        fi
    fi
done
