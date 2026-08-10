#!/bin/sh

set -eu

usage() {
  printf '%s\n' 'usage: install-hook.sh <absolute-store-root> [default-branch]' >&2
  exit 2
}

die() {
  printf '%s\n' "pr-context: $*" >&2
  exit 1
}

[ "$#" -ge 1 ] && [ "$#" -le 2 ] || usage

store_root=$1
case "$store_root" in
  /*) ;;
  *) die "store root must be absolute: $store_root" ;;
esac

repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || die "not inside a Git working tree"
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
sync_script="$script_dir/sync-pr-context.sh"
[ -x "$sync_script" ] || die "synchronization script is not executable: $sync_script"

if git -C "$repo_root" ls-files --error-unmatch -- PR.md >/dev/null 2>&1; then
  die "tracked PR.md must be resolved before installing managed context"
fi
if [ -e "$repo_root/PR.md" ] && [ ! -L "$repo_root/PR.md" ]; then
  die "existing non-symlink PR.md must be migrated before installation"
fi

mkdir -p "$store_root"
store_root=$(CDPATH= cd -- "$store_root" && pwd -P)
repo_root_physical=$(CDPATH= cd -- "$repo_root" && pwd -P)
case "$store_root/" in
  "$repo_root_physical"/*) die "store root must be outside the repository: $store_root" ;;
esac

if [ "$#" -eq 2 ]; then
  default_branch=$2
else
  origin_head=$(git symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null || :)
  if [ -n "$origin_head" ]; then
    default_branch=${origin_head#refs/remotes/origin/}
  elif git show-ref --verify --quiet refs/heads/main; then
    default_branch=main
  elif git show-ref --verify --quiet refs/heads/master; then
    default_branch=master
  else
    current_ref=$(git symbolic-ref --quiet HEAD 2>/dev/null || :)
    [ -n "$current_ref" ] || die 'cannot infer the default branch while HEAD is detached'
    default_branch=${current_ref#refs/heads/}
  fi
fi

git check-ref-format --branch "$default_branch" >/dev/null 2>&1 || die "invalid default branch: $default_branch"

git config --local prContext.storeRoot "$store_root"
git config --local prContext.defaultBranch "$default_branch"
git config --local prContext.syncScript "$sync_script"

exclude_file=$(git rev-parse --git-path info/exclude)
mkdir -p "$(dirname "$exclude_file")"
if [ ! -e "$exclude_file" ]; then
  : >"$exclude_file"
fi
if ! grep -Fqx '/PR.md' "$exclude_file"; then
  printf '%s\n' '/PR.md' >>"$exclude_file"
fi

"$sync_script"

hooks_path=$(git config --path --get core.hooksPath 2>/dev/null || :)
if [ -n "$hooks_path" ]; then
  printf '%s\n' "pr-context: configured branch store and current PR.md symlink"
  printf '%s\n' "pr-context: custom core.hooksPath is active: $hooks_path"
  printf '%s\n' "pr-context: add this command to its post-checkout integration:"
  printf '  "%s" "$@"\n' "$sync_script"
  exit 2
fi

hook_file=$(git rev-parse --git-path hooks/post-checkout)
if [ -e "$hook_file" ]; then
  if grep -q 'pr-context-hook' "$hook_file" 2>/dev/null; then
    git config --local prContext.hookIntegration managed
    printf '%s\n' "pr-context: managed post-checkout hook already installed: $hook_file"
    exit 0
  fi
  printf '%s\n' "pr-context: configured branch store and current PR.md symlink"
  printf '%s\n' "pr-context: existing post-checkout hook was not changed: $hook_file"
  printf '%s\n' "pr-context: chain this command while preserving the existing hook:"
  printf '  "%s" "$@"\n' "$sync_script"
  exit 2
fi

mkdir -p "$(dirname "$hook_file")"
{
  printf '%s\n' '#!/bin/sh'
  printf '%s\n' '# pr-context-hook v1'
  printf '%s\n' 'set -u'
  printf '%s\n' 'sync_script=$(git config --path --get prContext.syncScript 2>/dev/null || :)'
  printf '%s\n' '[ -z "$sync_script" ] || "$sync_script" "$@"'
} >"$hook_file"
chmod +x "$hook_file"
git config --local prContext.hookIntegration managed

printf '%s\n' "pr-context: configured shared store: $store_root"
printf '%s\n' "pr-context: configured default branch: $default_branch"
printf '%s\n' "pr-context: installed post-checkout hook: $hook_file"
