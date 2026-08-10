#!/bin/sh

set -eu

problem=0

report_problem() {
  printf '%s\n' "pr-context: $*" >&2
  problem=1
}

repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || {
  printf '%s\n' 'pr-context: not inside a Git working tree' >&2
  exit 1
}

store_root=$(git config --path --get prContext.storeRoot 2>/dev/null || :)
if [ -z "$store_root" ]; then
  report_problem 'prContext.storeRoot is not configured'
elif [ "${store_root#/}" = "$store_root" ]; then
  report_problem "prContext.storeRoot is not absolute: $store_root"
fi

branch_ref=$(git symbolic-ref --quiet HEAD 2>/dev/null || :)
if [ -n "$store_root" ]; then
  if [ -n "$branch_ref" ]; then
    branch=${branch_ref#refs/heads/}
    expected_target="$store_root/refs/heads/$branch/PR.md"
  else
    expected_target="$store_root/notices/detached-head/PR.md"
  fi

  if [ ! -L "$repo_root/PR.md" ]; then
    report_problem 'repository-root PR.md is not a symlink'
  else
    actual_target=$(readlink "$repo_root/PR.md")
    if [ "$actual_target" != "$expected_target" ]; then
      report_problem "PR.md points to $actual_target; expected $expected_target"
    fi
  fi
fi

hooks_path=$(git config --path --get core.hooksPath 2>/dev/null || :)
hook_integration=$(git config --get prContext.hookIntegration 2>/dev/null || :)
if [ -n "$hooks_path" ]; then
  if [ "$hook_integration" = "external" ]; then
    printf '%s\n' "pr-context: externally managed post-checkout integration recorded: $hooks_path"
  else
    report_problem "custom hooks path requires verified additive integration: $hooks_path"
  fi
else
  hook_file=$(git rev-parse --git-path hooks/post-checkout)
  if [ -x "$hook_file" ] && grep -q 'pr-context-hook' "$hook_file" 2>/dev/null; then
    printf '%s\n' "pr-context: managed post-checkout hook installed: $hook_file"
  elif [ "$hook_integration" = "external" ] && [ -x "$hook_file" ]; then
    printf '%s\n' "pr-context: externally managed post-checkout integration recorded: $hook_file"
  elif [ -e "$hook_file" ]; then
    report_problem "existing post-checkout hook requires verified additive integration: $hook_file"
  else
    report_problem "post-checkout hook is not installed: $hook_file"
  fi
fi

if [ "$problem" -ne 0 ]; then
  exit 1
fi

printf '%s\n' 'pr-context: branch store and current symlink are configured'
