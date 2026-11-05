#!/usr/bin/env bash
# Toggles Tokativ dictation and keeps Discord's microphone muted while Tokativ listens.
# Discord is unmuted once Tokativ closes the microphone, so a session ended with Enter, Escape or
# the pill restores it as well. Streams the user muted in Discord stay muted.
set -euo pipefail

state=${XDG_RUNTIME_DIR:-/tmp}/dictate
mkdir -p "$state"

# Succeeds while the Tokativ daemon holds a capture stream, which it does only while it listens.
listening() {
	local pids
	pids=$(pgrep -f '^[^ ]*tokativ daemon') || return 1
	pactl -f json list source-outputs | jq -e --arg pids "$pids" '
		($pids | split("\n")) as $pids
		| any(.[]; .properties["application.process.id"] | IN($pids[]))' >/dev/null
}

if listening; then
	exec tokativ toggle
fi

# A watcher left from the last session hands its streams to the one started below through the
# muted file, so stopping it loses nothing.
if [[ -f $state/watcher ]]; then
	kill "$(<"$state/watcher")" 2>/dev/null || true
fi

pactl -f json list source-outputs | jq -r '
	.[]
	| select(((.properties["application.name"] // "") + " " + (.properties["application.process.binary"] // "")) | test("discord|vesktop"; "i"))
	| select(.mute | not)
	| .index' | while read -r index; do
	pactl set-source-output-mute "$index" 1
	echo "$index" >>"$state/muted"
done

tokativ toggle

# Waits for the microphone to open, gives up after five seconds when it does not, then unmutes
# Discord once it closes.
(
	for _ in {1..50}; do
		listening && break
		sleep 0.1
	done
	while listening; do
		sleep 0.2
	done
	if [[ -f $state/muted ]]; then
		while read -r index; do
			pactl set-source-output-mute "$index" 0 || true
		done <"$state/muted"
		rm -f "$state/muted"
	fi
	if [[ $(<"$state/watcher") == "$BASHPID" ]]; then
		rm -f "$state/watcher"
	fi
) &
echo $! >"$state/watcher"
