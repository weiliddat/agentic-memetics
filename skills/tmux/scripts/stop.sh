#!/usr/bin/env bash
# Stop a process by interrupting it, then prove it actually died.
#
# C-c is sent to the pane, not to the process tree, so children get the signal
# the way they would if a human pressed it. Killing the window or the session
# instead leaves orphaned children behind for many process managers.
#
# usage: stop.sh <session> <window> [--force]
#   --force  kill the window if two interrupts fail (DESTROYS its scrollback)
#
# exit 0  dead (or already dead)
# exit 4  STILL RUNNING after two interrupts - nothing was destroyed
# exit 65 no such window
# exit 127 tmux is not installed

set -uo pipefail

SOCKET="$HOME/.tmux/sockets/agent.sock"
TIMEOUT="${TIMEOUT:-5}"

[ $# -ge 2 ] || {
	echo "usage: stop.sh <session> <window> [--force]" >&2
	exit 64
}
command -v tmux >/dev/null 2>&1 || {
	echo "tmux: NOT INSTALLED" >&2
	exit 127
}

SESSION="$1"
WINDOW="$2"
FORCE="${3:-}"
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
# '|'-delimited because pane_start_command contains spaces.
state() {
	t list-panes -t "$TARGET" \
		-F '#{pane_dead}|#{pane_dead_status}|#{pane_dead_signal}|#{?pane_start_command,#{pane_start_command},#{pane_current_command}}' \
		2>/dev/null | head -1
}

# A dead pane reports EITHER an exit status OR a fatal signal, never both:
# a process that traps INT and exits gives status 130, one that dies on the
# default handler gives signal 2. Both mean the interrupt landed.
how_it_died() {
	if [ -n "$status" ]; then
		echo "exit=$status"
	elif [ -n "$signal" ]; then
		echo "signal=$signal"
	else
		echo "exit=unknown"
	fi
}

read_state() { IFS='|' read -r dead status signal cmd <<<"$1"; }

s="$(state)"
[ -n "$s" ] || {
	echo "no such window: $SESSION:$WINDOW" >&2
	exit 65
}

read_state "$s"
if [ "$dead" = "1" ]; then
	echo "ALREADY DEAD  $SESSION:$WINDOW  $(how_it_died)"
	exit 0
fi

wait_dead() {
	local waited=0
	while [ "$waited" -lt "$TIMEOUT" ]; do
		sleep 1
		waited=$((waited + 1))
		read_state "$(state)"
		[ "$dead" = "1" ] && return 0
	done
	return 1
}

for attempt in 1 2; do
	echo "sending C-c to $SESSION:$WINDOW (attempt $attempt)"
	t send-keys -t "$TARGET" C-c
	if wait_dead; then
		echo "STOPPED  $SESSION:$WINDOW  $(how_it_died)"
		# tmux reports the signal by name ("int"), not by number.
		if [ "$status" = "130" ]; then
			echo "exit 130 = trapped SIGINT and shut itself down"
		else
			case "$signal" in
			int | INT | SIGINT | 2)
				echo "signal $signal = killed by SIGINT (no INT handler; normal)"
				;;
			esac
		fi
		echo "Output is still readable; respawn in place with start.sh."
		exit 0
	fi
done

echo "STILL RUNNING  $SESSION:$WINDOW  after 2 interrupts ($((TIMEOUT * 2))s)"
echo "current command: $cmd"
echo
tail_output 20

if [ "$FORCE" = "--force" ]; then
	echo
	echo "--force: killing the window. Its scrollback is gone."
	t kill-window -t "$TARGET"
	exit 0
fi

echo
echo "Nothing was destroyed. This process ignores SIGINT - it may need its own"
echo "quit command, or it is wedged. Tell the user before escalating; rerun with"
echo "--force only if they agree to lose this window's output."
exit 4
