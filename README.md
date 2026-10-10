# xmldocs

**An experimental Claude Code skill.** It starts from the thesis of
[*The Unreasonable Effectiveness of HTML*](https://claude.dev/blog/using-claude-code-the-unreasonable-effectiveness-of-html/)
(Thariq Shihipar, Anthropic): for documents an agent writes for people, HTML
works better than Markdown.

It tries a middle way:

- **the information stays in XML**: typed, validated, with metadata as
  attributes. It is more structured and easier to search than in Markdown or
  HTML;
- **the visual enrichment is delegated to XSLT**, which generates from the
  same XML an HTML view for people and a compact Markdown view for LLMs, the
  chat and GitHub.

Status: 0.1.0, created on 2026-10-10. Used on 4 documents. No automated tests.
Local only.

## What you gain and what you lose

You gain:

- validation: a fact without a source, or a plan phase started on an open
  decision, is an error;
- search and filters by attribute: every `open` decision, every fact verified
  only by reading the code;
- readable diffs of the source;
- a Markdown view that is cheap to read.

You lose:

- the made-to-measure HTML of the article. Here the HTML comes from a fixed
  template per document type and is static. `embed` covers the edge cases with
  hand-made SVG or HTML;
- hand editing: XML is awkward for a person, and the generated views must not
  be edited.

## What it does

| Type | Visibility | Use |
|---|---|---|
| `booklet` | public | instructions for what works today |
| `proposal` | public | a change not made yet |
| `plan` | private | implementation phases tied to decisions |
| `handoff` | private | what the next session needs |
| `note` | private | free internal note |

```
xmldocs/<type>/<name>.xml        source — the only file you edit
xmldocs/<type>/<name>.md         generated, committed (GitHub draws Mermaid)
xmldocs/<type>/<name>.html       generated, committed
temp/xmldocs/<type>/<name>.*     private: same three files, git-ignored
```

- `check` validates structure (XSD 1.0), executable content in embeds, and
  rules between attributes (ISO Schematron).
- `render` writes `.md` and `.html` beside each XML.
- `show` prints the Markdown view for the chat, optionally one part only;
  `show --diagrams` prints the diagrams and embeds, to be drawn with an inline
  widget.
- The script refuses a private document that git would track.

Why XML plus two generated views, with examples:
[`xmldocs/booklet/xmldocs.xml`](xmldocs/booklet/xmldocs.xml) (rendered:
[`.md`](xmldocs/booklet/xmldocs.md), [`.html`](xmldocs/booklet/xmldocs.html)).
Every element of the vocabulary:
[`sample-booklet.xml`](skills/xmldocs/examples/xmldocs/booklet/sample-booklet.xml).

## Measurements (one document, 2026-10-10)

| Same handoff | tokens |
|---|---|
| hand-written Markdown | 1,139 |
| XML source | 1,742 |
| generated Markdown view | 1,234 |
| generated HTML | 4,070 (1,530 of them CSS) |

- Counted with `tiktoken o200k_base`, not Claude's tokenizer: the ratios are
  indicative.
- The comparison is not information-equivalent: the xmldocs version carries
  source, method and date of 12 facts; the hand-written one the source of some.
- XML is **not** more compact than Markdown. Even with the same metadata it
  costs about 30% more (an estimate). Its advantage is validation, not size.

## When not to use it

- Narrative text without metadata: Markdown is shorter and enough.
- Documents a person edits by hand.
- Diagrams other than Mermaid, unless an `embed` is acceptable.

## Known limits

- The script does not detect Mermaid syntax errors; check the HTML in a browser.
- The Claude Code chat does not draw ` ```mermaid ` blocks; diagrams are shown
  with an inline HTML widget (`references/mermaid-widget.html`).
- The desktop app's side panel may show a local HTML as a static snapshot,
  where Mermaid does not run.
- Links between documents cannot be followed in the chat.
- XSD 1.0 and XSLT 1.0 only, through lxml.
- The view labels are English only; a per-language override is planned.
- Embed content is not validated: broken HTML breaks the page.
- The HTML loads Mermaid from jsdelivr: diagrams need network access.
- The vocabulary is small and will change with use. It is not a standard like
  DITA or DocBook.

## Requirements

- `uv`. Always run the script with `uv run --script` and an absolute path:
  when the path does not exist, uv falls back to the enclosing project and
  creates its `uv.lock` and `.venv`.
- A browser, to see the diagrams of the HTML view.

## Install for development

```bash
claude --plugin-dir ~/Sviluppo/claude_plugin/claude_xmldocs
```

## Documentation

The documentation is in `docs/` (Sphinx, MyST, Read the Docs theme). Two
pages include the generated Markdown views of the plugin's own booklets, and
the generated HTML views are published as they are under `views/`.

```bash
uv run --script "$PWD/skills/xmldocs/scripts/xmldocs.py" render xmldocs skills/xmldocs/examples/xmldocs
python3 docs/sync_views.py
uvx --from sphinx --with myst-parser --with sphinx-rtd-theme --with sphinxcontrib-mermaid \
    sphinx-build -W -b html docs docs/_build/html
```

## Use without Claude

```bash
uv run --script "$PWD/skills/xmldocs/scripts/xmldocs.py" render skills/xmldocs/examples/xmldocs
```

## License

Apache License 2.0. Copyright 2026 Giovanni Porcari. See [LICENSE](LICENSE).
