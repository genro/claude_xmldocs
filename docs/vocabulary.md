# Vocabulary

The base vocabulary is shared by every type (`schema/base.xsd`). Blocks are
allowed inside every part, `section`, `step`, `example` and `option`.

## Blocks

| Element | Attributes | Content |
|---|---|---|
| `p` | | inline text |
| `list` | `ordered`? | `item`+; an item may nest a `list` |
| `table` | `title`? | `row`+ (`head="true"` for the header) of `cell` |
| `code` | `lang`?, `file`? | source in CDATA |
| `diagram` | `kind="mermaid"`, `title`?, `id`? | Mermaid source in CDATA |
| `embed` | `kind="svg\|html"`, `title`, `summary`, `id`?, `scripts`? | hand-made SVG or HTML in CDATA |
| `fact` | `source`, `method="read\|test\|run"`, `verified`, `id`? | a verified statement |
| `rule` | `level="must\|must-not\|should"`, `why`?, `id`? | an obligation |
| `limit` | `source`?, `id`? | something not done today |
| `decision` | `id`, `status="open\|proposed\|decided\|rejected"` | `question`, `option`*, `choice`? |
| `example` | `title`, `id`? | blocks |
| `section` | `title`, `id`? | blocks; headings follow nesting |

Inline: `c` (code), `em`, `b`, `link href`, `ref to` (`doc="<type>/<name>"`
for another document).

## Facts

`method` says how the statement was verified: `read` in the code, `test`
covered by a test, `run` executed and observed. A statement that was not
verified is not a `fact`.

## Decisions

```xml
<decision id="d-cdata" status="decided">
  <question>How is code written?</question>
  <option id="d-cdata-a" title="CDATA"/>
  <option id="d-cdata-b" title="Manual escaping"/>
  <choice option="d-cdata-a" by="GP" date="2026-10-10">Readable for an LLM.</choice>
</decision>
```

A `decided` decision needs a `choice`; an `open` one cannot have it; the
choice must name one of its options.

## Embeds

`embed` covers the edge cases the vocabulary cannot express, with hand-made
SVG or HTML inserted as is into the HTML view. It is visual only: the required
`summary` carries the information in text, and the Markdown view shows title
and summary.

- Colours come from the page variables — `var(--fg)`, `var(--muted)`,
  `var(--panel)`, `var(--line)`, `var(--accent)`, `var(--ok)`, `var(--warn)`,
  `var(--bad)` — so the embed follows light and dark mode.
- Script tags, `on…=` handlers and `javascript:` URLs are refused unless the
  embed says `scripts="true"`. With it, `check` prints a warning and the HTML
  marks the embed `SCRIPT`.
- The content is not validated: broken HTML breaks the page.

## Writing rules

- Write `code`, `diagram` and `embed` bodies in CDATA; never escape by hand.
- Mermaid keywords (`loop`, `alt`, `opt`, `par`, `end`, `note`) cannot be
  participant names in a sequence diagram.
- Element and attribute names are English; content follows the document `lang`.
- The view labels are English; a per-language override is planned.
