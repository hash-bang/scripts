#!/bin/bash
# Vim + Which
# Automatically edits the executable specifed
# Usage: vw <command>

SRC=`which $1`
if [ "$?" != 0 ]; then
	echo "Cannot find executable for '$1'"
	exit 1
fi

echo "Editing '$SRC'..."
vi "$SRC"
