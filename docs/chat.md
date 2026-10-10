# Chat and diagrams

## Showing a document in the chat

`show` prints the Markdown view on stdout and writes no file. Claude pastes it
in the reply, so a document can be read without opening the side panel.
`--part` limits it to one child of the root — `next`, `decisions`, `phase`,
`step` — which keeps long documents out of the chat.

```bash
uv run --script "$X" show temp/xmldocs/handoff/2026-10-10.xml --part next
```

## Diagrams in the chat

The Claude Code chat does not draw ` ```mermaid ` blocks: they appear as code.
In the chat view a diagram or an embed is therefore one placeholder line.

`show --diagrams` prints the diagram sources and the embeds of the selection,
each after a `=== mermaid: <title> ===` line. Claude shows each one with the
inline HTML widget tool, filling `references/mermaid-widget.html`.

:::{note}
Keep the colour block of the widget template. With Mermaid's `base` theme in
dark mode, participant boxes have unreadable text until `actorBkg` and
`actorTextColor` are set.
:::

## Diagrams in the HTML view

The HTML view loads Mermaid from jsdelivr and draws the diagrams in the
browser, following light or dark mode. The script cannot detect Mermaid
syntax errors: open the HTML to check a diagram.

The side panel of the Claude desktop app may show a local HTML file as a
static snapshot, where Mermaid does not run. Serve the file over a local HTTP
server instead.

## On GitHub

The `.md` file written by `render` keeps diagrams as ` ```mermaid ` blocks,
which GitHub draws. Embeds appear as title and summary.
