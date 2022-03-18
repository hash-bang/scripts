#!/bin/bash
#
# Usage: `pipeline | e [args]`

HELP="
PIPELINE | e [options] [pipe-program]

Run STDIN via \`fzf\` and throw the resultant files into the default editor

-0, --zero              Read input as CHR(0) delimited instead of line-feeds
-n, --dry-run           Dont actually run any commands, just print the eventual command
-h, --help              Show command line help
"


# Defaults {{{
DRYRUN=0
FZFARGS="--multi --print0 --exit-0 --select-1"
# }}}

# Argument processing {{{
PARAMS=""
while (( "$#" )); do
	case "$1" in
		-0|---zero)
			FZFARGS="--read0 ${FZFARGS}"
			shift
			;;
		-n|--dry-run)
			DRYRUN=1
			shift
			;;
		-h|--help)
			echo "$HELP"
			exit 0
			;;
		--) # end argument parsing
			shift
			break
			;;
		-*|--*=) # unsupported flags
			if [ "$ACTION" == "auto" ]; then
				PARAMS="$PARAMS $1"
				shift
			else
				echo "Error: Unsupported flag $1" >&2
				exit 1
			fi
			;;
		*) # preserve positional arguments
			PARAMS="$PARAMS $1"
			shift
			;;
	esac
done
PARAMS=${PARAMS## } # remove leading spaces
# }}}

# Assume $EDITOR if $PARAMS is empty {{{
if [ -z "$PARAMS" ]; then
	PARAMS="${EDITOR:-vi}"
fi
# }}}


# Slurp STDIN -> LIST
LIST=$(</dev/stdin)

# Sanitise STDIN {{{
LIST=`echo "$LIST" | perl -pe 's/[^\p{Basic Latin}]+//g; s/\*$//g'`
# }}}

if [ "$DRYRUN" == 0 ]; then
	SELECTED=`echo "$LIST" | fzf $FZFARGS | tr -d '\0'`
	echo -e $SELECTED | xargs $PARAMS
else
	echo "e Dry-run:"
	echo " - USE FZF ARGS [$FZFARGS]"
	echo " - RUN THRU [xargs $PARAMS $LIST]"
fi
