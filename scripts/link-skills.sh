#!/bin/sh

set -eu

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
