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
- plugins/
  - [plain-writer.ts](plugins/plain-writer.ts): Amp plugin adding a `plain_writer` subagent tool that drafts text people read (PR descriptions, review comments, Slack messages, reports) from verified facts

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

## Plain writer plugin

[plugins/plain-writer.ts](plugins/plain-writer.ts) is an Amp plugin. It registers `plain_writer`, which hands the reader, what they need, the kind of text, the destination (GitHub, Slack, Linear or plain) and the facts to a separate subagent with a clean context and built-in writing rules. The main agent keeps investigating and judging; the writer only words the result, so the dense vocabulary of the investigation doesn't leak into what people read. The rules put the reader's time and understanding first and keep substantive evidence while dropping routine check results. Callers can pass a checkout path so the writer can read code (read-only) to decode jargon and quote short snippets, and media URLs for screenshots or videos. The caller still checks commits, paths and verdicts in the draft before posting.

The writer runs on GPT-6.1 Terra at medium reasoning effort, set by `MODEL` and `reasoningEffort` in the file. Across several rounds on real PR descriptions, Kira review comments, a thermos report and a Slack message, Terra at medium was the most accurate: it was the only configuration with no fact slips, while Terra at high and GPT-6.1 Sol at medium sometimes pulled details from the code that the facts didn't contain. Sol was also about twice as slow and broke the Slack rules.

Known gap: the writer is read-only by instruction only. Amp gives every plugin agent `tool_search` and `code_exec` even when `exclude` names them, and those calls don't reach the plugin's `tool.call` hook, so the writer could reach connected MCP servers through them (amp_bug_6VB97fwdHQzbzOPKFL7SHR). Its instructions forbid importing anything but the search tool.

To install, copy the file to the top level of the User Plugins repository listed by `amp plugins repositories`, then commit and push there. To adapt it for another agent, such as Kira, adjust the instructions and the tool description rather than the mechanism.

See [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md) for third-party work adapted by this repository.
