# Acknowledgments

## Thermos

The `thermo-nuclear-review`, `thermo-nuclear-code-quality-review`, and `thermos` skills are adapted from [Cursor's Thermos plugin](https://github.com/cursor/plugins/tree/1e5c90a4b6f249917bd21fe361b3a2a7deb741b8/thermos), including its two reviewer agents and three skill rubrics.

The adaptation removes Cursor-specific packaging and orchestration, gates invocation through descriptions, requires independent audits before discussion or cross-review reconciliation, and records reasons for rejected or deferred findings. The review standards are condensed rather than restored from this repository's retired copies.

The upstream work is Copyright (c) 2026 Cursor, licensed under MIT. Each adapted skill carries the complete notice in its own `LICENSE` file so it remains included when that skill is installed separately: [correctness review](skills/thermo-nuclear-review/LICENSE), [code-quality review](skills/thermo-nuclear-code-quality-review/LICENSE), and [composite](skills/thermos/LICENSE).

## tmux

The `tmux` skill is original to this repository, but its design draws on two prior public tmux skills:

- [`mitsuhiko/agent-stuff`](https://github.com/mitsuhiko/agent-stuff/tree/main/skills/tmux) — running agent sessions on a dedicated tmux socket rather than the user's default server, always surfacing a copy-paste command so a human can attach and watch, and the Python-REPL and lldb details.
- [`openclaw/openclaw`](https://github.com/openclaw/openclaw/tree/main/skills/tmux) — scoping the skill to processes that must be watched or interrupted, so one-shot commands keep using a plain shell.

No files were copied from either project. The state model, scripts, and tmux config here were written for this repository.
