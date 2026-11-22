#!/usr/bin/env bash
# Brings the Telegram window to the focused workspace and focuses it, or starts Telegram when it has no window.
set -euo pipefail

window=$(niri msg -j windows | jq -c 'first(.[] | select(.app_id == "org.telegram.desktop")) // empty')

if [[ -z "$window" ]]; then
	exec Telegram
fi

workspaces=$(niri msg -j workspaces)
target=$(jq -c 'first(.[] | select(.is_focused))' <<<"$workspaces")
id=$(jq -r '.id' <<<"$window")
source_ws=$(jq -r '.workspace_id' <<<"$window")
source_output=$(jq -r --argjson ws "$source_ws" 'first(.[] | select(.id == $ws)) | .output' <<<"$workspaces")
target_ws=$(jq -r '.id' <<<"$target")
target_output=$(jq -r '.output' <<<"$target")

# move-window-to-workspace resolves the index on the window's own monitor, so a window on
# another monitor goes through move-window-to-monitor, which lands it on the focused workspace.
if [[ "$source_ws" != "$target_ws" ]]; then
	if [[ "$source_output" != "$target_output" ]]; then
		niri msg action move-window-to-monitor --id "$id" "$target_output"
	else
		niri msg action move-window-to-workspace --window-id "$id" --focus false "$(jq -r '.idx' <<<"$target")"
	fi
fi

niri msg action focus-window --id "$id"
