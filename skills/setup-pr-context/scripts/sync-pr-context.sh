#!/bin/sh

set -eu

die() {
  printf '%s\n' "pr-context: $*" >&2
  exit 1
}

if [ "$#" -ge 3 ] && [ "$3" = "0" ]; then
  exit 0
fi

repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || die "not inside a Git working tree"
store_root=$(git config --path --get prContext.storeRoot 2>/dev/null || :)
[ -n "$store_root" ] || exit 0

case "$store_root" in
  /*) ;;
  *) die "prContext.storeRoot must be an absolute path: $store_root" ;;
esac

pr_link="$repo_root/PR.md"

if git -C "$repo_root" ls-files --error-unmatch -- PR.md >/dev/null 2>&1; then
  die "tracked PR.md cannot be replaced by the managed symlink"
fi

branch_ref=$(git symbolic-ref --quiet HEAD 2>/dev/null || :)
if [ -n "$branch_ref" ]; then
  case "$branch_ref" in
    refs/heads/*) ;;
    *) die "unexpected symbolic HEAD: $branch_ref" ;;
  esac
  branch=${branch_ref#refs/heads/}
  target="$store_root/refs/heads/$branch/PR.md"
  mkdir -p "$(dirname "$target")"

  if [ ! -e "$target" ]; then
    : >"$target"
  fi

  default_branch=$(git config --get prContext.defaultBranch 2>/dev/null || :)
  if [ -n "$default_branch" ] && [ "$branch" = "$default_branch" ] && [ ! -s "$target" ]; then
    {
      printf '%s\n' '<!-- pr-context: inactive -->'
      printf '%s\n\n' '# PR Context Notice'
      printf '%s\n\n' "You are on the default branch (\`$branch\`), not a pull-request branch."
      printf '%s\n' 'Are you sure you want to record pull-request working context here?'
    } >"$target"
  fi
else
  target="$store_root/notices/detached-head/PR.md"
  mkdir -p "$(dirname "$target")"
  if [ ! -s "$target" ]; then
    {
      printf '%s\n' '<!-- pr-context: inactive -->'
      printf '%s\n\n' '# PR Context Notice'
      printf '%s\n\n' 'HEAD is detached, so this checkout is not on a branch.'
      printf '%s\n' 'Switch to a pull-request branch before recording working context.'
    } >"$target"
  fi
fi

if [ -L "$pr_link" ]; then
  current_target=$(readlink "$pr_link")
  if [ "$current_target" = "$target" ]; then
    exit 0
  fi
  case "$current_target" in
    "$store_root"/*) rm -f "$pr_link" ;;
    *) die "refusing to replace unmanaged PR.md symlink: $current_target" ;;
  esac
elif [ -e "$pr_link" ]; then
  die "refusing to replace existing non-symlink PR.md"
fi

ln -s "$target" "$pr_link"
