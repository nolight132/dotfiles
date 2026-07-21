#!/usr/bin/env bash
set -euo pipefail

RULE_FILE="$HOME/.config/niri/screencast-privacy.kdl"
PID_FILE="${XDG_RUNTIME_DIR:-/tmp}/niri-telegram-screencast.pid"

hide() {
	cat > "$RULE_FILE" <<-'EOF'
	window-rule {
		match app-id=r#"^org\.telegram\.desktop$"#
		block-out-from "screencast"
	}
	EOF
}

notify() {
	command -v notify-send >/dev/null && notify-send -a niri "$@" || true
}

if grep -q block-out-from "$RULE_FILE" 2>/dev/null; then
	: > "$RULE_FILE"
	notify "Telegram visible" "Re-hiding in 1 minute"
	(
		sleep 60
		hide
		rm -f "$PID_FILE"
		notify "Telegram hidden"
	) &
	echo $! > "$PID_FILE"
else
	[[ -f "$PID_FILE" ]] && kill "$(cat "$PID_FILE")" 2>/dev/null || true
	rm -f "$PID_FILE"
	hide
	notify "Telegram hidden from screenshare"
fi
