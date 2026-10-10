<?xml version="1.0" encoding="UTF-8"?>
<!--
  xmldocs base stylesheet: page shell and templates for the base vocabulary.
  A type stylesheet imports this file and adds the template for its root.
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:include href="labels.xsl"/>

  <xsl:output method="html" encoding="UTF-8" indent="no"
              doctype-system="about:legacy-compat"/>

  <!-- ===== page shell ===== -->

  <xsl:template name="page">
    <xsl:param name="body"/>
    <html lang="{/*/@lang}">
      <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title><xsl:value-of select="/*/@title"/></title>
        <style><xsl:call-template name="css"/></style>
      </head>
      <body>
        <main>
          <header class="doc-head">
            <div class="doc-type"><xsl:call-template name="label"><xsl:with-param name="key" select="local-name(/*)"/></xsl:call-template></div>
            <h1><xsl:value-of select="/*/@title"/></h1>
            <div class="doc-meta">
              <span><xsl:value-of select="/*/@id"/></span>
              <span><xsl:value-of select="/*/@date"/></span>
              <xsl:if test="/*/@author"><span><xsl:value-of select="/*/@author"/></span></xsl:if>
              <xsl:if test="/*/@status"><span class="tag tag-{/*/@status}"><xsl:value-of select="/*/@status"/></span></xsl:if>
            </div>
          </header>
          <xsl:copy-of select="$body"/>
        </main>
        <xsl:if test="//diagram[@kind='mermaid']">
          <script type="module">
import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';
const dark = window.matchMedia('(prefers-color-scheme: dark)').matches;
mermaid.initialize({ startOnLoad: true, theme: dark ? 'dark' : 'neutral' });
          </script>
        </xsl:if>
      </body>
    </html>
  </xsl:template>

  <!-- A titled part of a type root (purpose, problem, ...): its title is its label.
       Low priority: a root child with its own template (step, phase, related,
       or any block of a note) is rendered by that template instead. -->
  <xsl:template match="/*/*" priority="-0.4">
    <section class="part {local-name()}">
      <h2><xsl:call-template name="label"><xsl:with-param name="key" select="local-name()"/></xsl:call-template></h2>
      <xsl:apply-templates/>
    </section>
  </xsl:template>

  <!-- ===== blocks ===== -->

  <xsl:template match="section">
    <section class="section">
      <xsl:if test="@id"><xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute></xsl:if>
      <xsl:element name="h{count(ancestor::section) + 3}">
        <xsl:value-of select="@title"/>
      </xsl:element>
      <xsl:apply-templates/>
    </section>
  </xsl:template>

  <xsl:template match="p"><p><xsl:apply-templates/></p></xsl:template>

  <xsl:template match="list[@ordered='true']"><ol><xsl:apply-templates/></ol></xsl:template>
  <xsl:template match="list"><ul><xsl:apply-templates/></ul></xsl:template>
  <xsl:template match="item"><li><xsl:apply-templates/></li></xsl:template>

  <xsl:template match="table">
    <div class="table-wrap">
      <table>
        <xsl:if test="@title"><caption><xsl:value-of select="@title"/></caption></xsl:if>
        <xsl:apply-templates/>
      </table>
    </div>
  </xsl:template>
  <xsl:template match="row"><tr><xsl:apply-templates/></tr></xsl:template>
  <xsl:template match="row[@head='true']/cell"><th><xsl:apply-templates/></th></xsl:template>
  <xsl:template match="cell"><td><xsl:apply-templates/></td></xsl:template>

  <xsl:template match="code">
    <figure class="code">
      <xsl:if test="@file or @lang">
        <figcaption>
          <xsl:value-of select="@file"/>
          <xsl:if test="@file and @lang"> · </xsl:if>
          <xsl:value-of select="@lang"/>
        </figcaption>
      </xsl:if>
      <pre><code><xsl:call-template name="trim-block"><xsl:with-param name="text" select="."/></xsl:call-template></code></pre>
    </figure>
  </xsl:template>

  <xsl:template match="diagram[@kind='mermaid']">
    <figure class="diagram">
      <xsl:if test="@id"><xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute></xsl:if>
      <pre class="mermaid"><xsl:call-template name="trim-block"><xsl:with-param name="text" select="."/></xsl:call-template></pre>
      <xsl:if test="@title"><figcaption><xsl:value-of select="@title"/></figcaption></xsl:if>
    </figure>
  </xsl:template>

  <xsl:template match="embed">
    <figure class="embed">
      <xsl:if test="@id"><xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute></xsl:if>
      <xsl:if test="@scripts = 'true' or @scripts = '1'">
        <div class="box-head"><span class="tag tag-script">script</span></div>
      </xsl:if>
      <div class="embed-body"><xsl:value-of select="." disable-output-escaping="yes"/></div>
      <figcaption><xsl:value-of select="@title"/></figcaption>
    </figure>
  </xsl:template>

  <xsl:template match="fact">
    <div class="box fact">
      <xsl:if test="@id"><xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute></xsl:if>
      <div class="box-head">
        <span class="tag tag-{@method}"><xsl:value-of select="@method"/></span>
        <code class="source"><xsl:value-of select="@source"/></code>
        <span class="muted"><xsl:value-of select="@verified"/></span>
      </div>
      <div><xsl:apply-templates/></div>
    </div>
  </xsl:template>

  <xsl:template match="rule">
    <div class="box rule rule-{@level}">
      <xsl:if test="@id"><xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute></xsl:if>
      <div class="box-head"><span class="tag tag-{@level}"><xsl:value-of select="@level"/></span></div>
      <div><xsl:apply-templates/></div>
      <xsl:if test="@why"><div class="muted why"><xsl:value-of select="@why"/></div></xsl:if>
    </div>
  </xsl:template>

  <xsl:template match="limit">
    <div class="box limit">
      <xsl:if test="@id"><xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute></xsl:if>
      <div><xsl:apply-templates/></div>
      <xsl:if test="@source"><div class="box-foot"><code class="source"><xsl:value-of select="@source"/></code></div></xsl:if>
    </div>
  </xsl:template>

  <xsl:template match="decision">
    <div class="box decision decision-{@status}" id="{@id}">
      <div class="box-head">
        <span class="tag tag-{@status}"><xsl:value-of select="@status"/></span>
        <span class="muted"><xsl:value-of select="@id"/></span>
      </div>
      <div class="question"><xsl:apply-templates select="question"/></div>
      <xsl:if test="option">
        <ol class="options"><xsl:apply-templates select="option"/></ol>
      </xsl:if>
      <xsl:apply-templates select="choice"/>
    </div>
  </xsl:template>
  <xsl:template match="question"><xsl:apply-templates/></xsl:template>
  <xsl:template match="option">
    <li id="{@id}">
      <xsl:if test="@id = ../choice/@option"><xsl:attribute name="class">chosen</xsl:attribute></xsl:if>
      <b><xsl:value-of select="@title"/></b>
      <xsl:apply-templates/>
    </li>
  </xsl:template>
  <xsl:template match="choice">
    <div class="choice">
      <b><xsl:call-template name="label"><xsl:with-param name="key" select="'choice'"/></xsl:call-template>: <xsl:value-of select="../option[@id = current()/@option]/@title"/></b>
      <xsl:if test="@by or @date">
        <span class="muted"> (<xsl:value-of select="@by"/><xsl:if test="@by and @date">, </xsl:if><xsl:value-of select="@date"/>)</span>
      </xsl:if>
      <xsl:if test="normalize-space(.)"><div><xsl:apply-templates/></div></xsl:if>
    </div>
  </xsl:template>

  <xsl:template match="example">
    <div class="box example">
      <xsl:if test="@id"><xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute></xsl:if>
      <div class="box-head"><b><xsl:value-of select="@title"/></b></div>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="related">
    <section class="part related">
      <h2><xsl:call-template name="label"><xsl:with-param name="key" select="'related'"/></xsl:call-template></h2>
      <ul><xsl:apply-templates/></ul>
    </section>
  </xsl:template>
  <xsl:template match="related/doc">
    <li>
      <xsl:choose>
        <xsl:when test="@href"><a href="{@href}"><xsl:value-of select="@id"/></a></xsl:when>
        <xsl:when test="contains(@id, '/')"><a href="../{@id}.html"><xsl:value-of select="@id"/></a></xsl:when>
        <xsl:otherwise><code><xsl:value-of select="@id"/></code></xsl:otherwise>
      </xsl:choose>
      <xsl:if test="@type"> <span class="tag"><xsl:value-of select="@type"/></span></xsl:if>
      <xsl:if test="normalize-space(.)"> — <xsl:value-of select="."/></xsl:if>
    </li>
  </xsl:template>

  <!-- ===== inline ===== -->

  <xsl:template match="c"><code><xsl:value-of select="."/></code></xsl:template>
  <xsl:template match="em"><em><xsl:value-of select="."/></em></xsl:template>
  <xsl:template match="b"><b><xsl:value-of select="."/></b></xsl:template>
  <xsl:template match="link"><a href="{@href}"><xsl:value-of select="."/></a></xsl:template>
  <!-- Documents live in xmldocs/html/<type>/<name>.html: doc="<type>/<name>". -->
  <xsl:template match="ref[@doc]">
    <a class="ref" href="../{@doc}.html#{@to}"><xsl:value-of select="."/></a>
  </xsl:template>
  <xsl:template match="ref"><a class="ref" href="#{@to}"><xsl:value-of select="."/></a></xsl:template>

  <!-- ===== helpers ===== -->

  <!-- Drop the leading newline and the trailing whitespace line of a CDATA body. -->
  <xsl:template name="trim-block">
    <xsl:param name="text"/>
    <xsl:variable name="head">
      <xsl:choose>
        <xsl:when test="starts-with($text, '&#10;')"><xsl:value-of select="substring($text, 2)"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="$text"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="rtrim"><xsl:with-param name="text" select="$head"/></xsl:call-template>
  </xsl:template>

  <xsl:template name="rtrim">
    <xsl:param name="text"/>
    <xsl:variable name="last" select="substring($text, string-length($text))"/>
    <xsl:choose>
      <xsl:when test="$last = ' ' or $last = '&#10;' or $last = '&#9;' or $last = '&#13;'">
        <xsl:call-template name="rtrim">
          <xsl:with-param name="text" select="substring($text, 1, string-length($text) - 1)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$text"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="css">
:root {
  --bg: #fbfaf7; --fg: #1d1d1b; --muted: #6b6a66; --line: #e2dfd8; --panel: #f3f1ec;
  --code-bg: #f0eee8; --accent: #2f5d8a;
  --ok: #2e7d4f; --warn: #a86b00; --bad: #b23b3b; --info: #2f5d8a;
}
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    --bg: #18181a; --fg: #e8e6e1; --muted: #9a9890; --line: #33332f; --panel: #212123;
    --code-bg: #26262a; --accent: #8fb4dc;
    --ok: #6cc28f; --warn: #e0a940; --bad: #e57373; --info: #8fb4dc;
  }
}
:root[data-theme="dark"] {
  --bg: #18181a; --fg: #e8e6e1; --muted: #9a9890; --line: #33332f; --panel: #212123;
  --code-bg: #26262a; --accent: #8fb4dc;
  --ok: #6cc28f; --warn: #e0a940; --bad: #e57373; --info: #8fb4dc;
}
* { box-sizing: border-box; }
body { margin: 0; background: var(--bg); color: var(--fg);
  font: 16px/1.55 -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }
main { max-width: 860px; margin: 0 auto; padding: 32px 16px 64px; }
h1 { font-size: 1.9rem; line-height: 1.2; margin: 4px 0 8px; }
h2 { font-size: 1.35rem; margin: 40px 0 12px; padding-bottom: 6px; border-bottom: 1px solid var(--line); }
h3 { font-size: 1.12rem; margin: 28px 0 8px; }
h4 { font-size: 1rem; margin: 20px 0 6px; }
a { color: var(--accent); }
code { font: 0.9em ui-monospace, SFMono-Regular, Menlo, monospace; background: var(--code-bg);
  padding: 1px 4px; border-radius: 4px; overflow-wrap: anywhere; }
pre { margin: 0; overflow-x: auto; }
pre code { display: block; padding: 12px 14px; background: none; }
figure { margin: 16px 0; }
figure.code { background: var(--code-bg); border-radius: 8px; }
figure.code figcaption { font-size: 0.8rem; color: var(--muted); padding: 8px 14px 0; }
figure.diagram { background: var(--panel); border: 1px solid var(--line); border-radius: 8px; padding: 12px; overflow-x: auto; }
figure.embed { background: var(--panel); border: 1px solid var(--line); border-radius: 8px; padding: 12px; overflow-x: auto; }
figure.embed figcaption { font-size: 0.85rem; color: var(--muted); text-align: center; margin-top: 8px; }
figure.embed svg { max-width: 100%; height: auto; }
.tag-script { color: var(--bad); }
figure.diagram figcaption { font-size: 0.85rem; color: var(--muted); text-align: center; margin-top: 8px; }
.doc-type { text-transform: uppercase; letter-spacing: 0.08em; font-size: 0.75rem; color: var(--muted); }
.doc-meta { display: flex; flex-wrap: wrap; gap: 12px; color: var(--muted); font-size: 0.9rem; }
.muted { color: var(--muted); font-size: 0.9em; }
.box { border: 1px solid var(--line); border-left: 4px solid var(--line); background: var(--panel);
  border-radius: 6px; padding: 10px 14px; margin: 12px 0; }
.box-head { display: flex; flex-wrap: wrap; align-items: center; gap: 8px; margin-bottom: 6px; }
.box-foot { margin-top: 6px; }
.box.fact { border-left-color: var(--info); }
.box.rule-must { border-left-color: var(--ok); }
.box.rule-must-not { border-left-color: var(--bad); }
.box.rule-should { border-left-color: var(--warn); }
.box.limit { border-left-color: var(--warn); }
.box.decision-open, .box.decision-proposed { border-left-color: var(--warn); }
.box.decision-decided { border-left-color: var(--ok); }
.box.decision-rejected { border-left-color: var(--bad); }
.box.example { border-left-color: var(--accent); }
.box.done { border-left-color: var(--ok); }
.tag-done { color: var(--ok); }
.tag-doing, .tag-in-progress { color: var(--info); }
.tag-todo { color: var(--muted); }
.tag-approved { color: var(--ok); }
.source { font-size: 0.8rem; }
.why { margin-top: 4px; }
.tag { display: inline-block; font-size: 0.72rem; font-weight: 600; text-transform: uppercase;
  letter-spacing: 0.04em; padding: 1px 7px; border-radius: 10px; border: 1px solid currentColor; color: var(--muted); }
.tag-test, .tag-run, .tag-must, .tag-decided, .tag-accepted { color: var(--ok); }
.tag-read, .tag-review { color: var(--info); }
.tag-should, .tag-open, .tag-proposed, .tag-draft { color: var(--warn); }
.tag-must-not, .tag-rejected { color: var(--bad); }
.options li { margin: 6px 0; }
.options li.chosen b { color: var(--ok); }
.choice { margin-top: 8px; padding-top: 8px; border-top: 1px dashed var(--line); }
.step-num { color: var(--muted); font-weight: 400; margin-right: 6px; }
.table-wrap { overflow-x: auto; margin: 16px 0; }
table { border-collapse: collapse; width: 100%; font-size: 0.95rem; }
caption { text-align: left; color: var(--muted); padding-bottom: 6px; }
th, td { border: 1px solid var(--line); padding: 6px 10px; text-align: left; vertical-align: top; }
th { background: var(--panel); }
  </xsl:template>

</xsl:stylesheet>
