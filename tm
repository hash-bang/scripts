#!/bin/bash
# Attach to the available TMUX session if any and optionally append a new window
# If an `@HOST` is specified, Mosh is used to dial into that machine before entering that machines local tmux
#
# Usage: tm [session="default"][@mosh-host] [options...]

INPUT=${1:-default}
shift

# Split on @ to detect remote host
if [[ "$INPUT" == *@* ]]; then
	SESSION="${INPUT%%@*}"
	HOST="${INPUT#*@}"
	SESSION="${SESSION:-default}"

	echo "Dialing into '$HOST' via mosh to establish Tmux session '$SESSION'"
	mosh "$HOST" -- ~/Scripts/tosh "$SESSION" "$@"
else
	SESSION="$INPUT"

	if tmux has-session -t "$SESSION" 2>/dev/null; then
		echo "Attaching to existing TMUX session '$SESSION'"
		tmux -2 attach-session -t "$SESSION"
	else
		echo "Starting new TMUX session '$SESSION'"
		tmux -2 new-session -s "$SESSION"
	fi
fi
