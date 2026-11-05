#!/usr/bin/env bash
# Starts Tokativ dictation with Discord's microphone muted, or confirms it and unmutes Discord.
# The Discord mute picks the direction, so a session ended some other way leaves Discord muted
# until the next press, which only unmutes it.
set -euo pipefail

streams=$(pactl -f json list source-outputs | jq -r '
	.[]
	| select(((.properties["application.name"] // "") + " " + (.properties["application.process.binary"] // "")) | test("discord|vesktop"; "i"))
	| "\(.index) \(.mute)"')

if [[ -z $streams ]]; then
	exec tokativ toggle
fi

set_mute() {
	while read -r index _; do
		pactl set-source-output-mute "$index" "$1"
	done <<<"$streams"
}

if grep -q ' false$' <<<"$streams"; then
	set_mute 1
	tokativ start
else
	tokativ confirm
	set_mute 0
fi
