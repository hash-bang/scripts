#!/bin/bash
# Merge a given path (or the root) with the Doop skeleton
# Usage: dm [path]

if [ -z "$1" ]; then
	echo "Merging root directories..."
	meld . "$HOME/Papers/Projects/Doop/skeleton"
else
	for FILE in "$@"; do
		RELATIVE="${FILE:-.}"
		echo "Merging relative path '$RELATIVE'..."
		meld "$RELATIVE" "$HOME/Papers/Projects/Doop/skeleton/$RELATIVE"
	done
fi
