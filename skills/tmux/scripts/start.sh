#!/usr/bin/env bash
# Start a long-running process in its own named window. Idempotent:
# an existing live window is never disturbed, an existing dead one is reused.
#
# usage: start.sh <session> <window> <command...>
#   e.g. start.sh weiliddat dev 'npm run dev'
#
# exit 0  started (CREATED or RESPAWNED) and still alive
# exit 2  ALREADY RUNNING - left untouched, nothing was started
# exit 3  DIED ON START - window kept so the output can be read
# exit 64 bad usage / bad session name
# exit 127 tmux is not installed

set -uo pipefail

SOCKET="$HOME/.tmux/sockets/agent.sock"
CONF="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/agent.tmux.conf"
STARTUP_WAIT="${STARTUP_WAIT:-2}"

[ $# -ge 3 ] || {
	echo "usage: start.sh <session> <window> <command...>" >&2
	exit 64
}
command -v tmux >/dev/null 2>&1 || {
	echo "tmux: NOT INSTALLED" >&2
	exit 127
}

SESSION="$1"
WINDOW="$2"
shift 2
CMD="$*"

case "$SESSION$WINDOW" in
*[:.]*)
	echo "bad name: ':' and '.' are not allowed in session or window names" >&2
	echo "sanitize first: lowercase, [^a-z0-9_-] -> '-'" >&2
	exit 64
	;;
esac

mkdir -p "$(dirname "$SOCKET")"
chmod 700 "$(dirname "$SOCKET")"

t() { tmux -S "$SOCKET" -f "$CONF" "$@"; }

# capture-pane returns the whole pane grid, so a short-output process comes back
# padded with blank rows. Trim trailing blanks, then take the last N real lines.
tail_output() {
	t capture-pane -pJ -S - -t "$SESSION:=$WINDOW" |
		awk '{ l[NR] = $0; if (NF) last = NR } END { for (i = 1; i <= last; i++) print l[i] }' |
		tail -n "${1:-20}"
}

# Always query state with list-panes, never display-message: given a target
# that does not exist, display-message exits 0 and returns the *current* pane's
# values, so a missing window looks like a running one. list-panes exits 1.
# '|'-delimited because pane_start_command contains spaces.
state() {
	t list-panes -t "$SESSION:=$WINDOW" \
		-F '#{pane_id}|#{pane_dead}|#{pane_dead_status}|#{pane_dead_signal}|#{?pane_start_command,#{pane_start_command},#{pane_current_command}}' \
		2>/dev/null | head -1
}

read_state() { IFS='|' read -r pane dead status signal cmd <<<"$1"; }

# -f only takes effect when this call is the one that starts the server, so
# passing it every time is harmless and guarantees a correctly-born server.
t has-session -t "=$SESSION" 2>/dev/null || t new-session -d -s "$SESSION" -n shell

existing="$(state)"

if [ -n "$existing" ]; then
	read_state "$existing"
	if [ "$dead" = "0" ]; then
		echo "ALREADY RUNNING  $SESSION:$WINDOW  ($pane)"
		echo "command: $cmd"
		echo
		echo "Nothing was started. Do NOT start a second copy silently - if this is"
		echo "a port/resource clash, ask the user which they want."
		echo
		tail_output 15
		exit 2
	fi
	t respawn-pane -k -t "$SESSION:=$WINDOW" "$CMD" || exit 1
	action=RESPAWNED
else
	t new-window -d -n "$WINDOW" -t "$SESSION:" "$CMD" || exit 1
	action=CREATED
fi

sleep "$STARTUP_WAIT"

after="$(state)"
[ -n "$after" ] || {
	echo "VANISHED  $SESSION:$WINDOW disappeared after starting - the server may have died" >&2
	exit 1
}
read_state "$after"

if [ "$dead" = "1" ]; then
	# A dead pane reports EITHER an exit status OR a fatal signal, never both.
	if [ -n "$status" ]; then
		died="exit=$status"
	elif [ -n "$signal" ]; then
		died="signal=$signal"
	else
		died="exit=unknown"
	fi
	echo "DIED ON START  $SESSION:$WINDOW  ($pane)  $died"
	echo "command: $CMD"
	[ "$status" = "127" ] && echo "exit 127 = command not found"
	echo
	tail_output 40
	echo
	echo "The window is kept so this output stays readable. Fix and re-run start.sh."
	exit 3
fi

echo "$action  $SESSION:$WINDOW  ($pane)  alive after ${STARTUP_WAIT}s"
echo "command: $CMD"
echo
echo "Watch it yourself with:"
echo "  tmux -S $SOCKET attach -t $SESSION"
echo "(run that from a plain terminal, not from inside tmux)"
