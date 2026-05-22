#!/bin/sh
# Open a code-diff-canvas HTML file in the system browser, falling back to
# printing a clickable file:// URL that the user (or a terminal that supports
# OSC 8 / click-to-open) can launch manually.
#
# POSIX sh, no Bash extensions. Always prints the file:// URL on stdout so
# callers (including agents) have something to surface to the user.

set -eu

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <path-to-html>" >&2
  exit 2
fi

target="$1"
[ -f "$target" ] || { echo "open.sh: not a file: $target" >&2; exit 1; }

# Resolve absolute path portably (no `realpath` on stock macOS sh).
case "$target" in
  /*) abs="$target" ;;
  *)  abs="$PWD/$target" ;;
esac

url="file://$abs"

# Try the system browser. We deliberately skip IDE-specific in-app browsers:
# their CLIs are inconsistent and the system browser works everywhere,
# including when launched from a VSCode/Cursor/Zed integrated terminal.
if command -v open >/dev/null 2>&1; then           # macOS
  open "$abs" >/dev/null 2>&1 || true
elif command -v xdg-open >/dev/null 2>&1; then     # Linux
  xdg-open "$abs" >/dev/null 2>&1 || true
fi

# Always emit the URL so the agent can include it in its reply.
echo "$url"
