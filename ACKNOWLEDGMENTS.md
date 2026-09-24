# Acknowledgments

## tmux

The `tmux` skill is original to this repository, but its design draws on two prior public tmux skills:

- [`mitsuhiko/agent-stuff`](https://github.com/mitsuhiko/agent-stuff/tree/main/skills/tmux) — running agent sessions on a dedicated tmux socket rather than the user's default server, always surfacing a copy-paste command so a human can attach and watch, and the Python-REPL and lldb details.
- [`openclaw/openclaw`](https://github.com/openclaw/openclaw/tree/main/skills/tmux) — scoping the skill to processes that must be watched or interrupted, so one-shot commands keep using a plain shell.

No files were copied from either project. The state model, scripts, and tmux config here were written for this repository.
