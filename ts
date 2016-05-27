#!/bin/bash
# Attach to the available TMUX session if any
# Usage: ts

TDIR=/tmp/tmux-`id -u`

if [ -d "$TDIR" ]; then
	echo "Attaching to existing TMUX session"
	tmux -2 -S "$TDIR/default" attach
	if [ "$?" == 1 ]; then
		echo "Failed to connect, starting new session"
		tmux -2
	fi
else
	echo "Starting new TMUX session"
	tmux -2
fi
