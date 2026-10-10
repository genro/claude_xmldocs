"""Sphinx configuration for the xmldocs documentation.

The narrative pages are Markdown (MyST). The design rationale and the sample
are the plugin's own xmldocs documents: their generated Markdown views are
included, and their generated HTML views are published as they are.
"""

project = "xmldocs"
author = "Giovanni Porcari"
copyright = "2026, Softwell S.r.l."
release = "0.1.0"
version = release

extensions = ["myst_parser", "sphinxcontrib.mermaid"]

exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]
source_suffix = {".md": "markdown"}
myst_heading_anchors = 3
myst_enable_extensions = ["colon_fence"]
# A ```mermaid fence in Markdown is handed to the ``mermaid`` directive.
myst_fence_as_directive = ["mermaid"]


# The generated HTML views, published unchanged next to the pages:
# views/booklet/xmldocs.html, views/booklet/sample-booklet.html.
html_extra_path = ["_views"]

html_theme = "sphinx_rtd_theme"
html_static_path = ["_static"]
# Keeps Mermaid diagrams light on the light theme (see the file).
html_js_files = ["light-theme.js"]
html_title = "xmldocs"
html_context = {
    "display_github": True,
    "github_user": "genro",
    "github_repo": "claude_xmldocs",
    "github_version": "main",
    "conf_py_path": "/docs/",
}
