#!/bin/bash
# Attach to the available TMUX session if any and optionally append a new window
# Usage: ts [command]

TDIR=/tmp/tmux-`id -u`

if [ -d "$TDIR" ]; then
	# Given a command to run?
	if [ -z "$1" ]; then
		echo "Attaching to existing TMUX session"
		tmux -2 -S "$TDIR/default" attach
		if [ "$?" == 1 ]; then
			echo "Failed to connect, starting new session"
			tmux -2
		fi
	else
		echo "Running command [$@] inside session"
		tmux -2 -S "$TDIR/default" new-window "$@"
		if [ "$?" == 1 ]; then
			echo "Failed to connect, starting new session"
			tmux -2 new-session \; new-window "$@" \; detach-client
		fi
	fi
else
	echo "Starting new TMUX session"
	tmux -2
fi
