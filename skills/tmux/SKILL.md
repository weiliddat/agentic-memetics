---
name: tmux
description: Run, watch, and interrupt long-lived processes (dev servers, watchers, test runners, REPLs, debuggers) in a private tmux server the user can also attach to. Use when a process must keep running while you do other things, when you need to read its output over time, or when you need to type into it. One-shot commands do NOT need this.
---

# tmux-managed processes

**One-shot commands → normal shell. This skill is for processes you need to watch or interrupt.**

If `npm test` finishes on its own and you just want the output, run it directly. Reach for tmux when the process outlives the command: a dev server, `--watch`, a REPL, a debugger, anything you will come back to or send keys to.

Requires tmux >= 3.0. If tmux is not installed, say so and stop — do not fall back to backgrounding with `&`.

## The model

Three things to hold in your head:

1. **One server**, on a hardcoded socket: `~/.tmux/sockets/agent.sock`. Private to agents. The user's own tmux and their `~/.tmux.conf` are untouched and invisible to it.
2. **One session per project**, named after the project. **One window per process**, named after the process. Never panes — pane indices renumber when siblings close, and split panes are too narrow for readable output.
3. **The process *is* the window's command.** There is no shell in the way. That buys a state machine with exactly three states:

| state | meaning | how you leave it |
|---|---|---|
| `DEAD=0` | running | `stop.sh` (sends C-c) |
| `DEAD=1`, `EXIT=n` / `EXIT=sigN` | exited, output still readable | `start.sh` (respawns in place) |
| absent | no such window | `start.sh` (creates it) |

A dead pane reports **either** an exit status **or** a fatal signal, never both. A process that traps `SIGINT` and shuts itself down gives `EXIT=130`; one that dies on the default handler gives `EXIT=sigint` (tmux reports signals by name, not number). **Both mean the C-c landed** — do not treat `sigint` as a failure.

Because `remain-on-exit` is on, exiting does not destroy the window. Output survives the process, and the exit code is readable via `EXIT`. Scrollback is 10k lines — a **ring buffer**, so a very chatty process still evicts its own early output. If the user needs complete logs, they need a real log file, not this.

Window `0` of every session is a plain `shell`. Leave it alone; it is there so a human who attaches has somewhere to type.

## Always check first

Resolve the skill directory once:

```sh
SKILL_DIR=~/.agents/skills/tmux   # or wherever this skill is linked
```

Then, before starting anything:

```bash
"$SKILL_DIR"/scripts/status.sh
```

One call, whole picture: whether the socket exists, whether a server is behind it, every session, every window with its command, dead flag, and exit code. A **stale** socket (file present, no server) is normal after a reboot — `start.sh` handles it; never delete it by hand.

Never start a process without checking whether it is already running.

## Naming

**Session = the project.** Use the git toplevel basename, so you get the same session from any subdirectory:

```bash
basename "$(git rev-parse --show-toplevel)"
```

For a linked worktree, suffix it with the worktree name (`myrepo-featurebranch`) — two worktrees of one repo share a basename and would otherwise collide.

Then sanitize it yourself: lowercase, replace every `[^a-z0-9_-]` with `-`, collapse repeats, trim leading/trailing `-`. tmux **rejects `.` and `:`** in these names, and directory names have dots all the time (`foo.com`, `my.project`). Not a script — just do it.

**Window = the process**, same sanitizing: `dev`, `api`, `test-watch`, `tsc`, `worker`, `python`, `lldb`. Name it for what it *is*, not for the command string.

## Starting

```bash
"$SKILL_DIR"/scripts/start.sh <session> <window> '<command>'
```

Creates the session if needed, creates the window if absent, **respawns in place if the window exists but is dead**, and refuses to touch it if it is alive. That is what keeps window count bounded: one window per process name, forever, no cleanup pass.

It then waits 2s and confirms the process is still alive, so a typo or a missing binary surfaces immediately as `DIED ON START exit=127` instead of looking like success. Exit codes: `0` alive, `2` already running, `3` died on start.

For a service with a readiness line, follow up with:

```bash
"$SKILL_DIR"/scripts/wait-for-text.sh <session> <window> 'ready in [0-9]+' 30
```

It gives up early if the process dies, so a crash never costs you the full timeout.

### When something is already running

`start.sh` exits `2` and starts nothing. **Do not quietly start a second copy, and do not quietly kill the first.** If it looks like a port or resource clash, ask the user which they meant:

> `api` is already running in session `myrepo` (port 3000). Do you want to reuse the running one, or should I configure this instance on a different port?

Then do what they say.

## Reading

```bash
tmux -S ~/.tmux/sockets/agent.sock capture-pane -pJ -S -200 -t '<session>:=<window>'
```

`-p` to stdout, `-J` joins wrapped lines, `-S -200` is the last 200 lines (`-S -` for everything). The `=` makes the target an exact match — without it tmux prefix-matches and `dev` happily hits `dev-server`.

Reading never requires attaching, and works the same for dead windows.

Two traps if you write tmux commands by hand instead of using the scripts:

- **Query state with `list-panes`, never `display-message`.** Given a target that does not exist, `display-message -p` exits **0** and returns the *current* pane's values — so a missing window looks like a healthy running one. `list-panes -t 'sess:=win'` exits 1 with no output, which is what you want.
- **`pane_current_command` reads `zsh` for everything**, because tmux runs the command through the shell and the shell does not exec-optimize it. Use `#{pane_start_command}` to find out what a window is actually running.
- `capture-pane` returns the whole 50-row pane grid, so short output arrives padded with blank lines. The scripts trim it; if you capture by hand, expect the padding.

Window geometry is pinned at 200x50 (`window-size manual`) precisely so captures do not reflow when a human attaches with a differently-sized terminal. Do not resize windows.

## Stopping

```bash
"$SKILL_DIR"/scripts/stop.sh <session> <window>
```

Sends **C-c to the pane** — the same signal path as a human pressing it, so children get it too. Do not use `kill-window`, `kill-session`, or `kill-server` to stop a process: many process managers leave orphaned children behind when the parent is killed out from under them, and killing the window throws away output you may still need.

`stop.sh` interrupts twice, polling for `DEAD=1` after each, and reports the exit code (`130` = clean SIGINT). If the process survives both, it destroys nothing and exits `4`. At that point tell the user — the process is ignoring SIGINT and may need its own quit command. Only pass `--force` (which kills the window and its scrollback) if they agree.

Leaving a stopped window in place is correct. It is readable, and `start.sh` will reuse it.

## Tell the user how to watch

A private socket means the user's plain `tmux ls` and `tmux attach` show **nothing** — different server. So every time you start a process, surface the exact command, with the real socket and session filled in:

```
tmux -S ~/.tmux/sockets/agent.sock attach -t <session>
```

`start.sh` prints this for you. Repeat it in your own message when you hand work back. Inside the session, `Ctrl-b w` lists every window by name, and the status bar flags the ones with new output.

Attaching must be done from a plain terminal. Nested tmux is not supported — if the user is already inside tmux, they need another terminal or window.

## REPLs and debuggers

These are the case where a window is genuinely interactive: start it, then drive it with `send-keys`.

```bash
tmux -S ~/.tmux/sockets/agent.sock send-keys -t '<session>:=<window>' -l 'print(x)'
tmux -S ~/.tmux/sockets/agent.sock send-keys -t '<session>:=<window>' Enter
```

`-l` sends the text literally; send `Enter` separately so nothing in the payload is interpreted as a key name.

- **Python**: `PYTHON_BASIC_REPL=1` is already set server-wide in `agent.tmux.conf`. The new REPL's cursor and bracketed-paste escapes corrupt `capture-pane` output; the basic one is plain text.
- **Debugging on macOS**: use `lldb`, not `gdb`. gdb needs code-signing that is usually absent, and fails in ways that look like your command was wrong.
- After every `send-keys`, capture and read before sending more. These are stateful; do not fire a sequence blind.

## Files

| file | purpose |
|---|---|
| `agent.tmux.conf` | the server's entire config; `-f` at server birth, because `history-limit` only applies to panes created after it is set |
| `scripts/status.sh` | everything running, one call |
| `scripts/start.sh` | idempotent create / respawn-in-place, with startup verification |
| `scripts/stop.sh` | C-c ladder with proof of death |
| `scripts/wait-for-text.sh` | poll for a pattern, bail early if the process dies |

## Never

- Run tmux without `-S ~/.tmux/sockets/agent.sock`. Bare `tmux` targets the user's server; `kill-server` there destroys their work.
- Use `kill-server` at all. Nothing in this skill needs it.
- Split panes.
- Start a duplicate of a running process, or kill one to make room, without asking.
- Source the user's `~/.tmux.conf`. Their `history-limit`, plugins, and mouse settings would corrupt captures.
