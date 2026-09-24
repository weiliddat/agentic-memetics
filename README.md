# agentic-memetics

Ideas, prompts, skills and guides for AI agents. Bootstrap agents to work my way.

- prompts/
  - [AGENTS.md](prompts/AGENTS.md): reusable agent instructions, versioned for comparison and refinement
- skills/
  - critique: critically walk through the intent, effectiveness, execution, and tradeoffs of any piece of work, software first
  - setup-pr-context: install shared branch-aware PR.md storage and additive checkout synchronization
  - maintain-pr-context: maintain the current branch's shared PR.md as the source of truth for Linear-linked work
  - code-walkthrough: walk through and explain a feature
  - tmux: run, watch, and interrupt long-lived processes on an isolated tmux server a human can also attach to

## Working with prompts

[prompts/AGENTS.md](prompts/AGENTS.md) contains the reusable agent prompt. The root [AGENTS.md](AGENTS.md) contains instructions for working in this repository.

Review pending prompt edits with `git diff -- prompts/AGENTS.md` and past revisions with `git log -p -- prompts/AGENTS.md`. Copy a reviewed revision into the instruction file used by your agent environment when ready to adopt it.

## Using selected skills

Link individual skill directories into the location that makes sense for your harness and scope. Use `~/.agents/skills/` as the global default, or a project-local or harness-specific skills directory when appropriate. Keep the destination as a real directory with one symlink per selected skill, rather than linking this repository's entire `skills/` directory.

For example, from this repository's root:

```sh
mkdir -p "$HOME/.agents/skills"
ln -s "$(pwd)/skills/critique" "$HOME/.agents/skills/"
```

Repeat for the skills you want. Include any sibling skills they depend on; for example, `maintain-pr-context` uses `setup-pr-context` for setup and repair.

See [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md) for third-party work adapted by this repository.
