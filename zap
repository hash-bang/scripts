#!/bin/bash
# Kill a running process via grep soft + wait + hard
# Usage: zap <grep...>

GREP="$1"

echo "Searching for process matching '$1'..."
FOUND=`ps -eo '%p %u %a' | grep "$GREP"`

echo -e "$FOUND"

echo "Killing softly..."
PIDS=`echo "$FOUND" | cut -d ' ' -f2`
for PID in $PIDS; do
	kill "$PID"
done

echo "Syncing..."
sync

echo "Wait 3..."
sleep 1

echo "Wait 2..."
sleep 1

echo "Wait 1..."
sleep 1

echo "Killing with shotgun..."
for PID in $PIDS; do
	kill -9 "$PID"
done
