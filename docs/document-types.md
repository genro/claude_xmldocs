# Document types

The root element is the document type. Each type has required parts, in order;
`?` marks an optional part, `+` a repeatable one.

| Root | Visibility | Purpose | Parts |
|---|---|---|---|
| `booklet` | public | How to do one thing with what exists today. Only verified behaviour. | `purpose`, `requires`?, `step`+, `rules`?, `limits`?, `facts`?, `decisions`?, `related`? |
| `proposal` | public | A change not made yet. | `problem`, `current`?, `solution`, `decisions`?, `consequences`?, `related`? |
| `plan` | private | Implementation plan: ordered code changes. | `goal`, `current`?, `decisions`?, `phase`+, `risks`?, `related`? |
| `handoff` | private | What the next session needs to continue. | `state`, `done`?, `next`, `decisions`?, `related`? |
| `note` | private | Internal note, free structure. | blocks, `related`? |

Every root carries `id`, `title`, `date` (YYYY-MM-DD), optional `lang`
(default `it`) and `author`. `proposal` carries `status`
(`draft|review|accepted|rejected`); `plan` carries `status`
(`draft|approved|in-progress|done`).

## Plan phases

A `phase` has `id`, `title`, `repo`, optional `status` (`todo|doing|done`),
`after` (ids of earlier phases) and `needs` (ids of decisions). It ends with
one `done` element: the criterion that closes the phase.

A phase that has started while a decision it `needs` is not `decided` is an
error. A plan that is `approved`, `in-progress` or `done` cannot have open
decisions.

## Public and private

Public documents are committed with their views. Private documents —
plans, handoffs, internal notes — never reach the repository: they live under
`temp/xmldocs/`, and the script refuses them if git would track the source or
a generated view.

A public document never links or names a private one. A private document
links a public one with an explicit relative `href`.

## Adding a type

1. `schema/<type>.xsd`: `xs:include` of `base.xsd`, a root element with the
   `docAttributes` group and its parts.
2. `xslt/<type>.xsl`: `xsl:import` of `base.xsl` and a template for
   `/<type>` that calls `page`. Part titles come from `xslt/labels.xsl`.
3. Rules between attributes go in `schema/rules.sch`.
4. A private type also goes in `PRIVATE_TYPES` in `scripts/xmldocs.py`.
