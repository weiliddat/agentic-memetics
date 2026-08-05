# Acknowledgments

The following skills are adapted from the Thermos plugin in Cursor's [`cursor/plugins`](https://github.com/cursor/plugins/tree/main/thermos) repository:

- `thermos`
- `thermo-nuclear-review`
- `thermo-nuclear-code-quality-review`

The original Thermos plugin was published by Cursor under the [MIT License](https://github.com/cursor/plugins/blob/main/thermos/LICENSE). This adaptation preserves the review rubrics and subagent behavior while replacing Cursor-specific agent types and orchestration syntax with harness-neutral subagent instructions.

The upstream plugin metadata credits Cursor as the author. The Thermos history in the source repository also credits Eric Zakariasson as a contributor.

## tmux

The `tmux` skill is original to this repository, but its design draws on two prior public tmux skills:

- [`mitsuhiko/agent-stuff`](https://github.com/mitsuhiko/agent-stuff/tree/main/skills/tmux) — running agent sessions on a dedicated tmux socket rather than the user's default server, always surfacing a copy-paste command so a human can attach and watch, and the Python-REPL and lldb details.
- [`openclaw/openclaw`](https://github.com/openclaw/openclaw/tree/main/skills/tmux) — scoping the skill to processes that must be watched or interrupted, so one-shot commands keep using a plain shell.

No files were copied from either project. The state model, scripts, and tmux config here were written for this repository.

## Thermos license notice

MIT License

Copyright (c) 2026 Cursor

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
