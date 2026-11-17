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

# Configure the running tmux server so mouse selections / copy-mode yanks go to the system clipboard
# and middle-click / prefix+] paste from it
# Falls back to OSC52 only (which Mosh relays to the local terminal) when no clipboard tool is available
tmux_clipboard() {
	local COPY="" PASTE=""

	if [[ -n "$WAYLAND_DISPLAY" ]] && command -v wl-copy >/dev/null; then
		COPY="wl-copy"
		PASTE="wl-paste -n"
	elif [[ -n "$DISPLAY" ]] && command -v xclip >/dev/null; then
		COPY="xclip -selection clipboard -in"
		PASTE="xclip -selection clipboard -out"
	elif [[ -n "$DISPLAY" ]] && command -v xsel >/dev/null; then
		COPY="xsel --clipboard --input"
		PASTE="xsel --clipboard --output"
	elif command -v pbcopy >/dev/null; then
		COPY="pbcopy"
		PASTE="pbpaste"
	fi

	tmux set -g mouse on
	tmux set -g set-clipboard on

	if [[ -n "$COPY" ]]; then
		# Default copy-mode bindings (MouseDragEnd1Pane, y, Enter) call copy-pipe-and-cancel which uses copy-command
		tmux set -g copy-command "$COPY"
		tmux bind -T copy-mode MouseDragEnd1Pane send -X copy-pipe-and-cancel
		tmux bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel
		tmux bind ] run -b "$PASTE | tmux load-buffer - && tmux paste-buffer -p"
		tmux bind -n MouseDown2Pane run -b "$PASTE | tmux load-buffer - && tmux paste-buffer -p -t '#{pane_id}'"
	fi
}

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
		tmux_clipboard
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
		tmux -2 new-session -d -s "$SESSION"
		tmux_clipboard
		tmux -2 attach-session -t "$SESSION"
	fi
fi
