---
name: setup-pr-context
description: Install, inspect, or repair shared branch-aware PR.md handling for repositories whose branches may be checked out across multiple clones. Use when asked to set up PR context, when maintain-pr-context delegates because its managed PR.md symlink or checkout synchronization is absent or incorrect, or when existing Git hooks must be integrated without replacing repository-managed hooks.
---

# Set Up PR Context

Give every branch one persistent `PR.md` in a project-specific external store shared by all clones. Expose the current branch's file through a repository-root `PR.md` symlink and synchronize that link after branch checkout.

## Preserve the architecture

- Configure the same absolute `prContext.storeRoot` in every clone of one project. Do not share a store between unrelated projects.
- Store branch notes at `<store>/refs/heads/<branch>/PR.md`. Preserve slashes in branch names.
- Keep an empty branch file as the inactive state. Do not populate it until pull-request context is activated.
- Put an inactive warning in the default branch's file. Use the shared detached-HEAD warning when no branch is checked out.
- Keep the reusable synchronization behavior in [`scripts/sync-pr-context.sh`](scripts/sync-pr-context.sh). Hook adapters must call this script instead of duplicating its logic.
- Never replace a tracked `PR.md`, an unmanaged symlink, or a regular file. Inspect and migrate legacy content deliberately.
- Never replace `core.hooksPath`. Git has one effective hooks directory, so integrate additively with the hook arrangement already in use.
- Treat the shared file as single-writer state. Coordinate simultaneous agents working on the same branch because ordinary file writes have no merge or conflict protection.

## Inspect before installing

1. Find the repository root, current branch or detached state, worktree status, remotes, `PR.md` file type and tracking state, `prContext.*` configuration, effective hooks directory, and existing `post-checkout` hook.
2. Run [`scripts/check-setup.sh`](scripts/check-setup.sh). Treat its nonzero result as a diagnosis, not permission to overwrite anything.
3. If `prContext.storeRoot` is absent, look for one unique value configured in sibling clones of the same project. Confirm repository identity from available remote and local context. If no safe value can be discovered, ask the user for the shared project-specific store path.
4. If a regular untracked `PR.md` exists, read it fully and determine which branch it belongs to. Move it into that branch's store path only when ownership is clear and the destination will not be overwritten. Ask when ambiguous.
5. If `PR.md` is tracked or repository policy conflicts with the architecture, stop and ask before changing tracking or ignore policy.

## Install or repair

1. Resolve this skill directory from this `SKILL.md`; do not assume a harness-specific skills environment variable.
2. Run [`scripts/install-hook.sh`](scripts/install-hook.sh) with the absolute shared store path and, when detection would be ambiguous, the default branch name. The script configures the clone, excludes root `PR.md` locally, synchronizes the current link, and installs a hook only when the default hook location is unused.
3. If the installer reports an existing hook or custom `core.hooksPath`, inspect that system before editing it:
   - Preserve every existing hook action and its exit behavior.
   - Use the hook manager's supported `post-checkout` extension when one exists.
   - Otherwise add a small dispatcher or wrapper that invokes the existing hook and `scripts/sync-pr-context.sh` with the original three arguments.
   - Keep only the adapter in the repository-specific hook system; keep all PR-context behavior in the shared script.
   - Do not edit a tracked hook or manager configuration without user authorization.
4. After verifying an external or manager-owned integration, record it with `git config --local prContext.hookIntegration external`. Do not set this marker before the adapter actually works.
5. Run the synchronization script directly after integrating a custom hook so the current branch is correct immediately.
6. Run `scripts/check-setup.sh` again. Verify `PR.md` resolves to the expected current target and `git status --short` does not report it.
7. Test one switch to another branch and back when safe. Confirm each branch resolves to its own persistent file and existing project hooks still run.

## Handle special states

- For the default branch, preserve the inactive warning unless the user explicitly chooses to maintain pull-request work there.
- For detached HEAD, point `PR.md` at the shared inactive detached-HEAD warning; do not create commit-keyed working context implicitly.
- After a branch rename, inspect the old managed target before synchronizing. Migrate it to the new branch path when the rename is known; ordinary checkout state alone cannot prove a rename.
- Leave branch files in the store after checkout or local branch deletion. Remove them only during explicit or confirmed PR cleanup.
