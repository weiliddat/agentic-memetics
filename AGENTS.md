# AGENTS.md

## General
- Read `README.md` for the repo index before making changes.
- Update `README.md` and `AGENTS.md` when changes make either file inaccurate or incomplete.

## skills/
- Keep skills harness-neutral. Do not depend on a specific host's agent types, tool names, or orchestration syntax; describe the capability needed ("the host harness's subagent mechanism") and give a fallback when it is absent.
- **Review skills fire manually only.** Any skill that produces a review (`deep-code-review`, `deep-thermos`, `thermos`, `thermo-nuclear-review`, `thermo-nuclear-code-quality-review`) must say `Use only when the user explicitly asks for <name> …` in its description. These passes are expensive and harsh; they must never auto-trigger off a generic "review this" or as a follow-up to unrelated work. Non-review skills (walkthroughs, formatting, rendering) may remain model-invocable.
- Gate invocation through the `description`, not host-specific frontmatter keys such as `disable-model-invocation`, which only some harnesses honor.
- Reference sibling skills **by file path**, not by skill name — a plain file read works in every harness, and it keeps manually-gated skills reachable from an orchestrator. Resolve paths relative to the skill's parent directory so they work in-repo and under a linked skills root.
- Point at `code-reference-formatting/SKILL.md` for code citations instead of restating reference rules. This applies to subagent reports as well as user-facing output.

## scripts/
- Write shell scripts for POSIX `sh` by default so they run on macOS and Linux; do not assume `bash` is available unless the task explicitly requires it.
- For portable scripts, avoid Bash-specific syntax and non-portable utility flags; if full portability is not possible, state that clearly in the change.
