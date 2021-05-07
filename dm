#!/bin/bash
# Merge a given path (or the root) with the Doop skeleton
# Usage: dm [path]

DOOP="$HOME/Papers/Projects/Doop/skeleton"

if [ -z "$1" ]; then
	echo "Merging root directories..."
	meld . "$DOOP"
else
	for FILE in "$@"; do
		RELATIVE="${FILE:-.}"
		echo "Merging relative path '$RELATIVE'..."
		meld "$RELATIVE" "$DOOP/$RELATIVE"
	done
fi
