"""Copy the generated HTML views into docs/_views/views/, which Sphinx publishes as is.

Run after `xmldocs.py render`. The copies are committed so that Read the Docs,
which does not run the renderer, publishes the same views.
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TARGET = ROOT / "docs" / "_views" / "views" / "booklet"
SOURCES = [
    ROOT / "xmldocs" / "booklet" / "xmldocs.html",
    ROOT / "skills" / "xmldocs" / "examples" / "xmldocs" / "booklet" / "sample-booklet.html",
]

# Links between the two views point across the repository tree; in the
# published folder the two files are siblings.
SIBLING_LINKS = {
    "../../skills/xmldocs/examples/xmldocs/booklet/sample-booklet.html": "sample-booklet.html",
    "../../../../../xmldocs/booklet/xmldocs.html": "xmldocs.html",
}

TARGET.mkdir(parents=True, exist_ok=True)
for source in SOURCES:
    text = source.read_text(encoding="utf-8")
    for old, new in SIBLING_LINKS.items():
        text = text.replace(f'href="{old}"', f'href="{new}"')
    (TARGET / source.name).write_text(text, encoding="utf-8")
    print(f"{source.relative_to(ROOT)} -> {(TARGET / source.name).relative_to(ROOT)}")
