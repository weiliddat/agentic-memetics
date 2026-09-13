# REPLs and debuggers

These are the case where a window is genuinely interactive: start it, then drive it with `send-keys`.

```bash
tmux -S ~/.tmux/sockets/agent.sock send-keys -t '<session>:=<window>' -l 'print(x)'
tmux -S ~/.tmux/sockets/agent.sock send-keys -t '<session>:=<window>' Enter
```

`-l` sends the text literally; send `Enter` separately so nothing in the payload is interpreted as a key name.

- **Python**: `PYTHON_BASIC_REPL=1` is already set server-wide in `agent.tmux.conf`. The new REPL's cursor and bracketed-paste escapes corrupt `capture-pane` output; the basic one is plain text.
- **Debugging on macOS**: use `lldb`, not `gdb`. gdb needs code-signing that is usually absent, and fails in ways that look like your command was wrong.
- After every `send-keys`, capture and read before sending more. These are stateful; do not fire a sequence blind.

