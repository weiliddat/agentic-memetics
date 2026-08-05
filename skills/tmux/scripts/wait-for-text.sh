#!/usr/bin/env bash
# Block until a pattern appears in a window's output. Bails out early if the
# process dies, so a crashed server never costs the full timeout.
#
# usage: wait-for-text.sh <session> <window> <extended-regex> [timeout-seconds]
#   e.g. wait-for-text.sh weiliddat dev 'ready in [0-9]+ ?ms' 30
#
# exit 0  matched
# exit 1  timed out, process still alive
# exit 3  process died before matching
# exit 65 no such window
# exit 127 tmux is not installed

set -uo pipefail

SOCKET="$HOME/.tmux/sockets/agent.sock"

[ $# -ge 3 ] || {
	echo "usage: wait-for-text.sh <session> <window> <regex> [timeout]" >&2
	exit 64
}
command -v tmux >/dev/null 2>&1 || {
	echo "tmux: NOT INSTALLED" >&2
	exit 127
}

SESSION="$1"
WINDOW="$2"
PATTERN="$3"
TIMEOUT="${4:-30}"
TARGET="$SESSION:=$WINDOW"

t() { tmux -S "$SOCKET" "$@"; }

# capture-pane returns the whole pane grid, so a short-output process comes back
# padded with blank rows. Trim trailing blanks, then take the last N real lines.
tail_output() {
	t capture-pane -pJ -S - -t "$TARGET" |
		awk '{ l[NR] = $0; if (NF) last = NR } END { for (i = 1; i <= last; i++) print l[i] }' |
		tail -n "${1:-20}"
}

# list-panes, not display-message: display-message exits 0 and returns the
# current pane's values for a target that does not exist.
state() {
	t list-panes -t "$TARGET" \
		-F '#{pane_dead}|#{pane_dead_status}|#{pane_dead_signal}' 2>/dev/null | head -1
}

[ -n "$(state)" ] || {
	echo "no such window: $SESSION:$WINDOW" >&2
	exit 65
}

waited=0
while :; do
	if t capture-pane -pJ -S -400 -t "$TARGET" | grep -Eq -- "$PATTERN"; then
		echo "MATCHED '$PATTERN' in $SESSION:$WINDOW after ${waited}s"
		exit 0
	fi

	IFS='|' read -r dead status signal <<<"$(state)"
	if [ "$dead" = "1" ]; then
		# A dead pane reports EITHER an exit status OR a fatal signal, never both.
		if [ -n "$status" ]; then
			died="exit=$status"
		elif [ -n "$signal" ]; then
			died="signal=$signal"
		else
			died="exit=unknown"
		fi
		echo "DIED  $SESSION:$WINDOW  $died  before matching '$PATTERN'"
		echo
		tail_output 40
		exit 3
	fi

	[ "$waited" -ge "$TIMEOUT" ] && break
	sleep 1
	waited=$((waited + 1))
done

echo "TIMEOUT after ${TIMEOUT}s waiting for '$PATTERN' in $SESSION:$WINDOW (still running)"
echo
tail_output 40
exit 1
