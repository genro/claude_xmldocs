#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = ["lxml>=5"]
# ///
"""Validate an xmldocs document and render it to HTML.

The root element names the type: <booklet> uses schema/booklet.xsd and
xslt/booklet.xsl. Validation runs XSD (structure) then rules.sch (rules
between attributes). Rendering runs only on a valid document.

    uv run --script xmldocs.py check <file-or-dir> ...
    uv run --script xmldocs.py render <file-or-dir> ...
    uv run --script xmldocs.py show <file> [--part <name>] [--diagrams]

`show` prints a Markdown view on stdout, to be shown inside the chat; it
writes no file. --part limits it to one child of the root (e.g. next).
--diagrams prints instead the source of every diagram in that selection,
one block per diagram, to be shown with references/mermaid-widget.html.

`render` writes <name>.html and <name>.md next to <name>.xml. Both start
with a comment saying they are generated. A directory means every *.xml
below it.
"""
from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path

from lxml import etree, isoschematron

SKILL_DIR = Path(__file__).resolve().parent.parent
SCHEMA_DIR = SKILL_DIR / "schema"
XSLT_DIR = SKILL_DIR / "xslt"

# Types that must never reach the repository: they live under a git-ignored
# folder (temp/xmldocs/<type>/ by convention). Everything else is committed.
PRIVATE_TYPES = {"plan", "handoff", "note"}


# Executable content inside an <embed>: script tags, on* handlers, javascript: URLs.
EXECUTABLE = re.compile(r"<script\b|\son[a-z]+\s*=|javascript:", re.IGNORECASE)


def embed_findings(tree: etree._ElementTree) -> tuple[list[str], list[str]]:
    """Errors for executable embeds without scripts="true"; warnings for those with it."""
    errors, warnings = [], []
    for embed in tree.iter("embed"):
        if not EXECUTABLE.search(embed.text or ""):
            continue
        label = embed.get("id") or embed.get("title")
        if embed.get("scripts") in ("true", "1"):
            warnings.append(f"line {embed.sourceline}: embed '{label}' runs scripts (scripts=\"true\")")
        else:
            errors.append(f"line {embed.sourceline}: embed '{label}' contains executable content; "
                          f"add scripts=\"true\" if intended")
    return errors, warnings


def doc_type(tree: etree._ElementTree) -> str:
    tag = tree.getroot().tag
    if not (SCHEMA_DIR / f"{tag}.xsd").is_file():
        known = sorted(p.stem for p in SCHEMA_DIR.glob("*.xsd") if p.stem != "base")
        raise SystemExit(f"unknown document type <{tag}>; known types: {', '.join(known)}")
    return tag


def validate(tree: etree._ElementTree) -> list[str]:
    kind = doc_type(tree)
    errors = []
    xsd = etree.XMLSchema(etree.parse(str(SCHEMA_DIR / f"{kind}.xsd")))
    if not xsd.validate(tree):
        errors += [f"line {e.line}: {e.message}" for e in xsd.error_log]
        return errors
    errors += embed_findings(tree)[0]
    if errors:
        return errors
    sch = isoschematron.Schematron(etree.parse(str(SCHEMA_DIR / "rules.sch")), store_report=True)
    if not sch.validate(tree):
        ns = {"svrl": "http://purl.oclc.org/dsdl/svrl"}
        for failed in sch.validation_report.findall(".//svrl:failed-assert", ns):
            text = " ".join(failed.findtext("svrl:text", namespaces=ns).split())
            errors.append(f"{failed.get('location')}: {text}")
    return errors


def privacy_errors(source: Path, kind: str) -> list[str]:
    """A private type must be ignored by git, together with its HTML output."""
    if kind not in PRIVATE_TYPES:
        return []
    errors = []
    for path in (source, *outputs(source)):
        probe = subprocess.run(["git", "check-ignore", "-q", str(path)],
                               cwd=source.resolve().parent, capture_output=True)
        if probe.returncode == 128:
            return []  # not inside a git repository
        if probe.returncode != 0:
            errors.append(f"private type <{kind}>: {path} is not ignored by git; "
                          f"put it under temp/xmldocs/{kind}/ with temp/ in .gitignore")
    return errors


def render(tree: etree._ElementTree) -> str:
    kind = doc_type(tree)
    transform = etree.XSLT(etree.parse(str(XSLT_DIR / f"{kind}.xsl")))
    return str(transform(tree))


def outputs(source: Path) -> tuple[Path, Path]:
    """The generated files of a source: HTML and Markdown, beside it."""
    return source.with_suffix(".html"), source.with_suffix(".md")


def generated_note(source: Path) -> str:
    return f"<!-- generated from {source.name} by xmldocs: do not edit, edit the XML -->"


def expand(paths: list[Path]) -> list[Path]:
    files = []
    for path in paths:
        if path.is_dir():
            files += sorted(path.rglob("*.xml"))
        else:
            files.append(path)
    return files


def markdown(tree: etree._ElementTree, part: str = "", diagrams: str = "fence") -> str:
    transform = etree.XSLT(etree.parse(str(XSLT_DIR / "md.xsl")))
    result = transform(tree, part=etree.XSLT.strparam(part), diagrams=etree.XSLT.strparam(diagrams))
    return str(result).rstrip() + "\n"


def diagrams(tree: etree._ElementTree, part: str = "") -> str:
    root = tree.getroot()
    scope = [root] if not part else [e for e in root if e.tag == part]
    blocks = []
    for element in scope:
        for visual in element.iter("diagram", "embed"):
            label = visual.get("title") or visual.get("id") or visual.tag
            kind = visual.get("kind") if visual.tag == "diagram" else f"embed {visual.get('kind')}"
            blocks.append(f"=== {kind}: {label} ===\n{visual.text.strip()}\n")
    return "\n".join(blocks)


def main() -> int:
    parser = argparse.ArgumentParser(prog="xmldocs")
    sub = parser.add_subparsers(dest="command", required=True)
    for name in ("check", "render"):
        cmd = sub.add_parser(name)
        cmd.add_argument("sources", type=Path, nargs="+")
    show = sub.add_parser("show")
    show.add_argument("source", type=Path)
    show.add_argument("--part", default="")
    show.add_argument("--diagrams", action="store_true")
    args = parser.parse_args()

    if args.command == "show":
        tree = etree.parse(str(args.source))
        errors = validate(tree)
        if errors:
            print(f"{args.source}: {len(errors)} error(s)", file=sys.stderr)
            for error in errors:
                print(f"  {error}", file=sys.stderr)
            return 1
        sys.stdout.write(diagrams(tree, args.part) if args.diagrams
                         else markdown(tree, args.part, diagrams="placeholder"))
        return 0

    sources = expand(args.sources)
    failed = 0
    for source in sources:
        tree = etree.parse(str(source))
        errors = validate(tree) or privacy_errors(source, tree.getroot().tag)
        if errors:
            failed += 1
            print(f"{source}: {len(errors)} error(s)", file=sys.stderr)
            for error in errors:
                print(f"  {error}", file=sys.stderr)
            continue
        for warning in embed_findings(tree)[1]:
            print(f"{source}: warning: {warning}", file=sys.stderr)
        if args.command == "check":
            print(f"{source}: valid <{tree.getroot().tag}>")
            continue
        html_file, md_file = outputs(source)
        doctype, _, page = render(tree).partition("\n")
        html_file.write_text(f"{doctype}\n{generated_note(source)}\n{page}", encoding="utf-8")
        md_file.write_text(f"{generated_note(source)}\n\n{markdown(tree)}", encoding="utf-8")
        print(f"{source} -> {html_file.name}, {md_file.name}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
