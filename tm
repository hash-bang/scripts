#!/bin/bash
# Attach to the available TMUX session if any and optionally append a new window
# If an `@HOST` is specified, Mosh is used to dial into that machine before entering that machines local tmux
#
# Usage: tm [session="default"][@mosh-host] [options...]
#
# Options:
#   -r, --read-only    Attach to an existing session in read-only mode

READONLY=0
INPUT=""
ARGS=()

for ARG in "$@"; do
	case "$ARG" in
		-r|--read-only)
			READONLY=1
			;;
		*)
			if [[ -z "$INPUT" ]]; then
				INPUT="$ARG"
			else
				ARGS+=("$ARG")
			fi
			;;
	esac
done

INPUT=${INPUT:-default}

# Split on @ to detect remote host
if [[ "$INPUT" == *@* ]]; then
	SESSION="${INPUT%%@*}"
	HOST="${INPUT#*@}"
	SESSION="${SESSION:-default}"

	[[ "$READONLY" == 1 ]] && ARGS+=("--read-only")

	echo "Dialing into '$HOST' via mosh to establish Tmux session '$SESSION'"
	mosh "$HOST" -- ~/Scripts/tm "$SESSION" "${ARGS[@]}"
else
	SESSION="$INPUT"

	if tmux has-session -t "$SESSION" 2>/dev/null; then
		if [[ "$READONLY" == 1 ]]; then
			echo "Attaching to existing TMUX session '$SESSION' (read-only)"
			tmux -2 attach-session -r -t "$SESSION"
		else
			echo "Attaching to existing TMUX session '$SESSION'"
			tmux -2 attach-session -t "$SESSION"
		fi
	elif [[ "$READONLY" == 1 ]]; then
		echo "TMUX session '$SESSION' does not exist - cannot attach read-only" >&2
		exit 1
	else
		echo "Starting new TMUX session '$SESSION'"
		tmux -2 new-session -s "$SESSION"
	fi
fi
