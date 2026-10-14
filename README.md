# agentic-memetics

Ideas, prompts, skills and guides for AI agents. Bootstrap agents to work my way.

- prompts/
  - [AGENTS.md](prompts/AGENTS.md): reusable agent instructions, versioned for comparison and refinement
  - [PUCK.md](prompts/PUCK.md): personal instructions for Amp's Puck meta agent, loaded in every Puck conversation
- skills/
  - critique: critically walk through the intent, effectiveness, execution, and tradeoffs of any piece of work, software first
  - thermo-nuclear-review: audit correctness, security, breakage, developer experience, and feature-gate leaks
  - thermo-nuclear-code-quality-review: audit structure, simplification, canonical ownership, reuse, and maintainability
  - thermos: combine both independent thermo audits, prioritizing findings and recording reasons for rejection or deferral
  - setup-pr-context: install shared branch-aware PR.md storage and additive checkout synchronization
  - maintain-pr-context: maintain the current branch's shared PR.md as the source of truth for Linear-linked work
  - code-walkthrough: walk through and explain a feature
  - tmux: run, watch, and interrupt long-lived processes on an isolated tmux server a human can also attach to

## Working with prompts

[prompts/AGENTS.md](prompts/AGENTS.md) contains the reusable agent prompt. [prompts/PUCK.md](prompts/PUCK.md) contains my personal instructions for Amp's Puck meta agent. The root [AGENTS.md](AGENTS.md) contains instructions for working in this repository.

Review pending prompt edits with `git diff -- prompts/AGENTS.md prompts/PUCK.md` and past revisions with `git log -p -- prompts/AGENTS.md` (or `prompts/PUCK.md`). Copy a reviewed revision into the instruction file used by your agent environment (for Puck, its personal instructions setting) when ready to adopt it.

## Using selected skills

Link individual skill directories into the location that makes sense for your harness and scope. Use `~/.agents/skills/` as the global default, or a project-local or harness-specific skills directory when appropriate. Keep the destination as a real directory with one symlink per selected skill, rather than linking this repository's entire `skills/` directory.

For example, from this repository's root:

```sh
mkdir -p "$HOME/.agents/skills"
ln -s "$(pwd)/skills/critique" "$HOME/.agents/skills/"
```

Repeat for the skills you want. Include any sibling skills they depend on; `thermos` needs both `thermo-nuclear-review` and `thermo-nuclear-code-quality-review`, and `maintain-pr-context` uses `setup-pr-context` for setup and repair.

For persistent personal Amp skills, copy the selected skill directories unchanged to the top level of the User Skills repository listed by `amp skills repositories`, then commit and push there. This is how `critique` and the thermos pack are installed; it is a separate copy, not an automatic sync from this repository. New threads pick up pushed revisions; use Amp's skill reload in an existing thread.

## Thermos reviews

Ask explicitly for `thermo-nuclear-review`, `thermo-nuclear-code-quality-review`, or `thermos`; generic review requests do not invoke them. Each reviewer forms its findings before reading PR discussion or another reviewer's output. `thermos` uses isolated reviewers when the harness supports them, with a sequential fallback that discloses any loss of independence. Its combined report includes prioritized, deduplicated findings and a later **Not worth fixing now** section explaining every rejected or deferred reviewer finding. `deep-thermos` and `deep-code-review` remain retired.

See [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md) for third-party work adapted by this repository.
