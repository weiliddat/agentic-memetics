#!/usr/bin/env bash
# Everything that is running, in one call. Run this before anything else.
#
# usage: status.sh
#
# exit 0  always (absence of a server is information, not an error)
# exit 127 tmux is not installed

set -uo pipefail

SOCKET="$HOME/.tmux/sockets/agent.sock"

command -v tmux >/dev/null 2>&1 || {
	echo "tmux: NOT INSTALLED (install it before using this skill)" >&2
	exit 127
}

# Warn rather than fail: on an old tmux it is still better to report what is
# running than to refuse. Version strings look like "tmux 3.7b" or "tmux next-3.5".
version="$(tmux -V | grep -oE '[0-9]+\.[0-9]+' | head -1)"
if [ -n "$version" ]; then
	major="${version%%.*}"
	minor="${version##*.}"
	if [ "$major" -lt 3 ] || { [ "$major" -eq 3 ] && [ "$minor" -lt 4 ]; }; then
		echo "WARNING: tmux $version is older than the required 3.4." >&2
		echo "         pane_dead_signal is unavailable, so a process killed by C-c" >&2
		echo "         will report exit=unknown instead of the signal." >&2
		echo >&2
	fi
fi

if [ ! -S "$SOCKET" ]; then
	echo "socket:   absent    $SOCKET"
	echo "server:   not running"
	echo "sessions: none"
	exit 0
fi

if ! tmux -S "$SOCKET" list-sessions >/dev/null 2>&1; then
	echo "socket:   STALE     $SOCKET"
	echo "server:   not running (socket file is leftover from a dead server)"
	echo "sessions: none"
	echo
	echo "Nothing is running. start.sh will replace the stale socket; do not delete it by hand."
	exit 0
fi

echo "socket:   live      $SOCKET"
echo "server:   running"
echo
echo "sessions:"
tmux -S "$SOCKET" list-sessions \
	-F '  #{session_name}  windows=#{session_windows}  attached=#{session_attached}'

echo
printf '  %-30s %-5s %-6s %-5s %s\n' TARGET DEAD EXIT PANE COMMAND
# pane_start_command, not pane_current_command: tmux runs the command through
# the shell, which does not exec-optimize, so pane_current_command reads "zsh"
# for every window. Fall back to the current command for the plain shell window.
tmux -S "$SOCKET" list-panes -a -F \
	'#{session_name}:#{window_name}|#{pane_dead}|#{pane_dead_status}|#{pane_dead_signal}|#{pane_id}|#{?pane_start_command,#{pane_start_command},#{pane_current_command}}' |
	while IFS='|' read -r target dead status signal pane cmd; do
		# A dead pane reports EITHER an exit status OR a fatal signal, never both.
		if [ "$dead" != "1" ]; then
			exitcol='-'
		elif [ -n "$status" ]; then
			exitcol="$status"
		elif [ -n "$signal" ]; then
			exitcol="sig$signal"
		else
			exitcol='?'
		fi
		printf '  %-30s %-5s %-6s %-5s %s\n' \
			"$target" "$dead" "$exitcol" "$pane" "${cmd:--}"
	done

echo
echo "DEAD=0 running - DEAD=1 exited, output still readable, respawn with start.sh"
echo "EXIT 130 or sigint = interrupted by C-c - 127 = command not found - 0 = finished cleanly"
