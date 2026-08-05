# agentic-memetics

Ideas, skills, guides for AI agents. Bootstrap agents to work my way.

- scripts/
  - link-skills.sh: link ./skills/ to where coding agents look for skills, e.g. ~/.agents/skills/
- skills/
  - code-reference-formatting: format code references and previews in a portable way
  - code-diff-canvas: render code chunks and diffs as a self-contained HTML page (Pierre Diffs + Shiki, SSR)
  - deep-code-review: perform a deep structured code review
  - pr-walkthrough: walk through a PR in a semantic, structured way
  - code-walkthrough: walk through and explain a feature
  - thermo-nuclear-review: audit a change set for correctness, security, breakage, and feature-gate leaks
  - thermo-nuclear-code-quality-review: apply a strict maintainability and structural-simplification rubric
  - thermos: delegate both thermo-nuclear reviews and synthesize their findings
  - deep-thermos: run deep-code-review plus both thermo-nuclear passes in one wave and synthesize a single report
  - tmux: run, watch, and interrupt long-lived processes on an isolated tmux server a human can also attach to

See [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md) for third-party work adapted by this repository.
