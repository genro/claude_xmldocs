---
name: xmldocs
description: Write project documents as typed XML — instruction booklet, proposal, implementation plan, handoff, internal note — validated by XSD and Schematron; XSLT generates beside each XML an HTML view for people and a compact Markdown view for LLMs, the chat and GitHub. Plans, handoffs and notes are private (temp/xmldocs, git-ignored). Supports Mermaid diagrams and hand-made SVG/HTML embeds. Use when the user asks for a booklet, a proposal, a plan, a handoff, "scrivilo in xmldocs", "documento xml", to show an xmldocs document in the chat, or wants a document whose facts, rules and decisions carry their source, status and date as attributes.
---

# xmldocs

One XML file per document. The root element is the document type. Metadata
(source of a fact, status of a decision, level of a rule) are attributes, not
sentences. The HTML is generated; never edit it.

## Types

| Root | Visibility | Purpose | Required parts, in order |
|---|---|---|---|
| `booklet` | public | How to do one thing with what exists today. Only verified behaviour. | `purpose`, `requires`?, `step`+, `rules`?, `limits`?, `facts`?, `decisions`?, `related`? |
| `proposal` | public | A change not made yet. | `problem`, `current`?, `solution`, `decisions`?, `consequences`?, `related`? |
| `plan` | private | Implementation plan: ordered code changes. | `goal`, `current`?, `decisions`?, `phase`+, `risks`?, `related`? |
| `handoff` | private | What the next session needs to continue. | `state`, `done`?, `next`, `decisions`?, `related`? |
| `note` | private | Internal note, free structure. | blocks, `related`? |

Every root carries `id`, `title`, `date` (YYYY-MM-DD), optional `lang`
(default `it`) and `author`. `proposal` also carries `status`
(`draft|review|accepted|rejected`); `plan` carries `status`
(`draft|approved|in-progress|done`).

A `phase` has `id`, `title`, `repo`, optional `status` (`todo|doing|done`),
`after` (ids of earlier phases) and `needs` (ids of decisions that must be
decided before it starts). It holds blocks and ends with one `done` element:
the criterion that closes the phase.

## Repository layout

Public types are committed; private types never reach the repository. The
generated files sit beside their source.

```
<repo>/xmldocs/<type>/<name>.xml        public source — the only file you edit
<repo>/xmldocs/<type>/<name>.md         generated, committed (GitHub draws Mermaid)
<repo>/xmldocs/<type>/<name>.html       generated, committed
<repo>/temp/xmldocs/<type>/<name>.*     private: same three files, git-ignored
```

Both generated files start with a comment naming their source. Never edit them.

The script refuses a private document whose source or generated files git
does not ignore. If the repository has no ignored `temp/`, ask the user
before adding `temp/` to `.gitignore`.

A document's address is `<type>/<name>` (e.g. `booklet/kajenn-app`). Inside
one tree use it in `ref doc="…"` and `related/doc id="…"`.

Across trees:
- a public document never links or names a private one — the reader of the
  repository cannot open it;
- a private document links a public one with an explicit relative `href`:
  from `temp/xmldocs/<type>/` that is `../../../xmldocs/<type>/<name>.html`.

## Base vocabulary (all types)

Blocks, allowed inside every part, `section`, `step`, `example` and `option`:

- `p` — paragraph with inline content.
- `list` (`ordered="true"` optional) of `item`; items may nest a `list`.
- `table` (`title`?) of `row` (`head="true"` for the header) of `cell`.
- `code` (`lang`?, `file`?) — body in CDATA.
- `diagram kind="mermaid"` (`title`?, `id`?) — body in CDATA.
- `embed kind="svg|html" title=… summary=…` (`id`?, `scripts="true"`?) — hand-made
  SVG or HTML for an edge case the vocabulary cannot express. Body in CDATA,
  inserted as is into the HTML view. It is visual only: `summary` carries the
  information in text, and the Markdown view shows only title and summary.
  Colours come from the page variables (`var(--fg)`, `var(--muted)`,
  `var(--panel)`, `var(--line)`, `var(--accent)`, `var(--ok)`, `var(--warn)`,
  `var(--bad)`), so the embed follows light and dark mode. Script tags, `on…=`
  handlers and `javascript:` URLs are refused unless `scripts="true"`; with it,
  `check` prints a warning and the HTML marks the embed `SCRIPT`.
- `fact source="path:line" method="read|test|run" verified="YYYY-MM-DD"` — a
  verified statement. `read` = read in the code; `test` = covered by a test;
  `run` = executed and observed.
- `rule level="must|must-not|should"` (`why`?) — an obligation.
- `limit` (`source`?) — something the subject does not do today.
- `decision id=… status="open|proposed|decided|rejected"` containing
  `question`, then `option id=… title=…`*, then `choice option=… by=… date=…`?.
- `example title=…` — blocks, usually `p` plus `code`.
- `section title=…` (`id`?) — nests blocks; headings follow nesting depth.

Inline: `c` (code), `em`, `b`, `link href=…`, `ref to=…` (`doc="<type>/<name>"`
for another document).

## Writing rules

- Verify every `fact` with tools before writing it. A statement you could not
  verify is not a `fact`: say so in a `p`, or leave it out.
- `code` and `diagram` bodies always go in `<![CDATA[ … ]]>`. Never escape by hand.
- Mermaid keywords cannot be participant names in a sequence diagram (`loop`,
  `alt`, `opt`, `par`, `end`, `note`, …). Use names like `EventLoop`.
- A booklet holds no open design discussion. Put it in a proposal and point to
  it with one `decision status="open"` plus `related`.
- Write content in the document `lang`; element and attribute names stay English.
- Do not add elements or attributes outside the schema. If a document needs a
  new element, propose the schema change to the user first.

## Workflow

The script lives at `scripts/xmldocs.py` in this skill's directory (resolve the
path from where this SKILL.md was loaded). It needs `lxml`; `uv run --script`
installs it in an isolated environment. Always pass `--script` and an absolute
path: when the path does not exist, uv falls back to the enclosing project, and a plain
`uv run` inside a project creates that project's `uv.lock` and `.venv`.

1. Write `xmldocs/<type>/<name>.xml` (public) or `temp/xmldocs/<type>/<name>.xml` (private).
2. `uv run --script <skill>/scripts/xmldocs.py check xmldocs temp/xmldocs` — XSD then
   `schema/rules.sch` on every source. Fix every error; errors carry the line
   or the XPath.
3. `uv run --script <skill>/scripts/xmldocs.py render xmldocs temp/xmldocs` — writes
   `<name>.html` and `<name>.md` beside every source. A single file works too.
4. If the document has a `diagram`, open the HTML through a local HTTP server
   and check the diagram rendered: Mermaid runs in the browser, so the script
   cannot detect a Mermaid syntax error.

## Showing a document in the chat

`uv run --script <skill>/scripts/xmldocs.py show <file> [--part <name>]` prints a
Markdown view (`xslt/md.xsl`) on stdout and writes no file. Paste that output
in the reply, unchanged, when the user asks to see a document in the chat
instead of the side panel. `--part` takes the name of one child of the root
(`next`, `decisions`, `phase`, `step`, …): prefer it to the whole document.

The chat does not draw Mermaid: in the Markdown view a diagram is one
placeholder line, `*[diagramma: <title>]*`. To show the diagrams, run
`show <file> [--part <name>] --diagrams`, which prints each source after a
`=== mermaid: <title> ===` line, and show each one with the visualization
widget tool, filling `references/mermaid-widget.html` (`__MERMAID__` = the
source, `__ID__` = a short unique id). Keep its colour block: without it the
participant boxes are unreadable in dark mode. If no widget tool is available,
point to the HTML file instead.

`--diagrams` also prints every `embed` (`=== embed svg: <title> ===`); show
an SVG or HTML embed with the same widget tool, passing its body as is.

`examples/xmldocs/booklet/sample-booklet.xml` uses every base element.

## Adding a type

1. `schema/<type>.xsd`: `xs:include` of `base.xsd`, a root element with
   `docAttributes` and its parts.
2. `xslt/<type>.xsl`: `xsl:import` of `base.xsl`, a `type-label` param, a
   template for `/<type>` calling `page`, one template per part calling `part`.
3. Rules between attributes go in `schema/rules.sch`.
4. Add the type to the table above with its visibility; a private type also
   goes in `PRIVATE_TYPES` in `scripts/xmldocs.py`.
