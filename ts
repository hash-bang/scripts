#!/bin/bash
# Attach to the available TMUX session if any and optionally append a new window
# Usage: ts [session="default"] [options...]

SESSION=${1:-default}
shift

if tmux has-session -t "$SESSION"; then
	echo "Attaching to existing TMUX session '$SESSION'"
	tmux -2 attach-session -t "$SESSION"
else
	echo "Starting new TMUX session '$SESSION'"
	tmux -2 new-session -s "$SESSION"
fi
