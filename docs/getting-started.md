# Getting started

## Requirements

- [Claude Code](https://claude.com/claude-code).
- [`uv`](https://docs.astral.sh/uv/). The script declares its dependency
  (`lxml`) inline, and `uv run --script` installs it in an isolated
  environment.
- A browser with network access, to see the Mermaid diagrams of the HTML view.

## Install the plugin

Clone the repository and start Claude Code with it:

```bash
git clone https://github.com/genro/claude_xmldocs.git ~/claude_xmldocs
claude --plugin-dir ~/claude_xmldocs
```

The skill is called `xmldocs`. Ask Claude for a booklet, a proposal, a plan or
a handoff "in xmldocs", and it writes the XML, validates it and generates the
views.

## Layout in your repository

```text
xmldocs/<type>/<name>.xml        source — the only file you edit
xmldocs/<type>/<name>.md         generated, committed
xmldocs/<type>/<name>.html       generated, committed
temp/xmldocs/<type>/<name>.*     private documents: same three files, git-ignored
```

Public types are committed. Private types (`plan`, `handoff`, `note`) live
under `temp/`, which must be git-ignored: the script refuses a private
document that git would track. See [document types](document-types.md).

## The script

The skill drives one script, `skills/xmldocs/scripts/xmldocs.py`. You can also
run it yourself:

```bash
X=~/claude_xmldocs/skills/xmldocs/scripts/xmldocs.py
uv run --script "$X" check xmldocs temp/xmldocs      # validate
uv run --script "$X" render xmldocs temp/xmldocs     # write .md and .html
uv run --script "$X" show xmldocs/booklet/x.xml --part rules   # Markdown on stdout
```

| Command | Effect |
|---|---|
| `check <file-or-dir>…` | XSD of the document type, executable-content check of embeds, Schematron rules. |
| `render <file-or-dir>…` | `check`, then `<name>.html` and `<name>.md` beside each XML. |
| `show <file> [--part P] [--diagrams]` | Markdown view on stdout, for the chat; writes nothing. |

:::{warning}
Always pass `--script` and an **absolute** script path. When the path does not
exist, `uv run` falls back to the project in the current directory and creates
its `uv.lock` and `.venv`.
:::

## A first document

```xml
<?xml version="1.0" encoding="UTF-8"?>
<booklet id="booklet/hello" title="Hello xmldocs" date="2026-10-10" lang="en">
  <purpose><p>Shows the smallest valid booklet.</p></purpose>
  <step title="Run check"><p>Then run <c>render</c>.</p></step>
</booklet>
```

Save it as `xmldocs/booklet/hello.xml`, then `check` and `render` it.
