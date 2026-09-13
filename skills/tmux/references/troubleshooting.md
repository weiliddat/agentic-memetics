# State queries and captured output

When writing manual state queries or diagnosing misleading output, keep these command behaviors in mind:

- **Query state with `list-panes`, never `display-message`.** Given a target that does not exist, `display-message -p` exits **0** and returns the *current* pane's values — so a missing window looks like a healthy running one. `list-panes -t 'sess:=win'` exits 1 with no output, which is what you want.
- **`pane_current_command` can identify the shell instead of the intended process**, because the startup command runs through a shell. Use `#{pane_start_command}` to find out what a window is actually running.
- `capture-pane` returns the whole 50-row pane grid, so short output arrives padded with blank lines. The scripts trim it; if you capture by hand, expect the padding.

