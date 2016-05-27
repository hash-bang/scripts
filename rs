#!/bin/bash
# Alias of rsync
# This exists only because I cant figure out how to turn off the *&($#*&$@# broken auto-complete in ZSH
rsync -auv --progress "$@"
