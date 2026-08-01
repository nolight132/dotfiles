#!/usr/bin/env bash

set -euo pipefail

wallpaper=${NOCTALIA_WALLPAPER_PATH:-}
[[ -n $wallpaper && -f $wallpaper ]] || exit 0

state_dir=${XDG_RUNTIME_DIR:-/tmp}/noctalia-matugen
mkdir -p "$state_dir"

exec 9>"$state_dir/lock"
flock 9

readonly debounce_secs=5
stamp=$state_dir/last
now=$(date +%s)
if [[ -f $stamp ]]; then
  read -r prev_time prev_path < "$stamp" || true
  if [[ ${prev_path-} == "$wallpaper" && $((now - ${prev_time:-0})) -lt $debounce_secs ]]; then
    exit 0
  fi
fi
printf '%s %s\n' "$now" "$wallpaper" > "$stamp"

mode=${NOCTALIA_THEME_MODE:-}
if [[ -z $mode ]]; then
  settings=${XDG_STATE_HOME:-$HOME/.local/state}/noctalia/settings.toml
  mode=$(sed -n '/^\[theme\]/,/^\[/{s/^mode = "\([a-z]*\)".*/\1/p;}' "$settings" 2>/dev/null | head -1)
fi
[[ $mode == light ]] || mode=dark

exec >"$state_dir/log" 2>&1 </dev/null
echo "matugen image --mode $mode -- $wallpaper"
matugen image --mode "$mode" --source-color-index 0 -- "$wallpaper"
