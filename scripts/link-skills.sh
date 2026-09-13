#!/bin/sh

set -eu

# WARNING: This legacy script links the entire skills directory.
# Prefer a real ~/.agents/skills directory with symlinks to individual selected
# skills so only those skills are exposed to coding agents.
printf '%s\n' \
  'WARNING: This script links the entire skills directory.' \
  'Recommended: keep ~/.agents/skills as a real directory and symlink only the individual skills you want.' >&2

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
source_dir="$repo_root/skills"
target_dir="$HOME/.agents/skills"

if [ -e "$target_dir" ] || [ -L "$target_dir" ]; then
  echo "$target_dir already exists"
  exit 0
fi

mkdir -p "$(dirname "$target_dir")"
ln -s "$source_dir" "$target_dir"

echo "Linked $source_dir -> $target_dir"
