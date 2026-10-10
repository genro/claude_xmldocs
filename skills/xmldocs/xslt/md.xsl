<?xml version="1.0" encoding="UTF-8"?>
<!--
  xmldocs Markdown view, for showing a document inside the chat.
  One stylesheet for every type: the type roots share the same parts.

  Param `part`: the local name of one child of the root (e.g. "next",
  "decisions"); empty renders the whole document.

  Whitespace: blocks are reached with select="*" only, so the indentation
  of the source never reaches the output; text inside inline content is
  normalized in mode "inline", keeping one space at its edges.
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:include href="labels.xsl"/>

  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:param name="part" select="''"/>
  <!-- "fence": a ```mermaid block, drawn by GitHub (the .md file).
       "placeholder": one line, for the chat, which does not draw Mermaid. -->
  <xsl:param name="diagrams" select="'fence'"/>

  <xsl:variable name="nl" select="'&#10;'"/>

  <!-- ===== document ===== -->

  <xsl:template match="/*">
    <xsl:choose>
      <xsl:when test="$part != ''">
        <xsl:if test="not(*[local-name() = $part])">
          <xsl:message terminate="yes">no part named '<xsl:value-of select="$part"/>' in this document</xsl:message>
        </xsl:if>
        <xsl:apply-templates select="*[local-name() = $part]" mode="part"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('## ', @title, $nl)"/>
        <xsl:text>*</xsl:text><xsl:call-template name="label"><xsl:with-param name="key" select="local-name()"/></xsl:call-template><xsl:value-of select="concat(' · ', @id, ' · ', @date)"/>
        <xsl:if test="@status"><xsl:value-of select="concat(' · ', @status)"/></xsl:if>
        <xsl:value-of select="concat('*', $nl, $nl)"/>
        <xsl:apply-templates select="*" mode="part"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- A child of the root: a titled part, or a step / phase, or a bare block (note). -->
  <xsl:template match="*" mode="part">
    <xsl:variable name="title">
      <xsl:call-template name="part-title"><xsl:with-param name="name" select="local-name()"/></xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="self::step or self::phase">
        <xsl:apply-templates select="."/>
      </xsl:when>
      <xsl:when test="$title != ''">
        <xsl:value-of select="concat('### ', $title, $nl, $nl)"/>
        <xsl:apply-templates select="*"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="part-title">
    <xsl:param name="name"/>
    <xsl:if test="contains($part-names, concat(' ', $name, ' '))">
      <xsl:call-template name="label"><xsl:with-param name="key" select="$name"/></xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- ===== blocks ===== -->

  <xsl:template match="step | phase">
    <xsl:value-of select="concat('#### ', count(preceding-sibling::*[local-name() = local-name(current())]) + 1, '. ', @title, $nl)"/>
    <xsl:if test="self::phase">
      <xsl:value-of select="concat('`', substring(concat(@status, 'todo'), 1, string-length(@status) + 4 * number(not(@status))), '` · ', @repo)"/>
      <xsl:if test="@after"><xsl:text> · </xsl:text><xsl:call-template name="label"><xsl:with-param name="key" select="'after'"/></xsl:call-template><xsl:value-of select="concat(': ', @after)"/></xsl:if>
      <xsl:if test="@needs"><xsl:text> · </xsl:text><xsl:call-template name="label"><xsl:with-param name="key" select="'needs'"/></xsl:call-template><xsl:value-of select="concat(': ', @needs)"/></xsl:if>
      <xsl:value-of select="$nl"/>
    </xsl:if>
    <xsl:value-of select="$nl"/>
    <xsl:apply-templates select="*"/>
  </xsl:template>

  <xsl:template match="phase/done">
    <xsl:text>**</xsl:text><xsl:call-template name="label"><xsl:with-param name="key" select="'done-when'"/></xsl:call-template><xsl:text>:** </xsl:text>
    <xsl:apply-templates mode="inline"/>
    <xsl:value-of select="concat($nl, $nl)"/>
  </xsl:template>

  <xsl:template match="section">
    <xsl:value-of select="concat('#### ', @title, $nl, $nl)"/>
    <xsl:apply-templates select="*"/>
  </xsl:template>

  <xsl:template match="p">
    <xsl:apply-templates mode="inline"/>
    <xsl:value-of select="concat($nl, $nl)"/>
  </xsl:template>

  <xsl:template match="list">
    <xsl:apply-templates select="item"/>
    <xsl:if test="not(parent::item)"><xsl:value-of select="$nl"/></xsl:if>
  </xsl:template>

  <xsl:template match="item">
    <xsl:variable name="depth" select="count(ancestor::list) - 1"/>
    <xsl:call-template name="indent"><xsl:with-param name="n" select="$depth * 3"/></xsl:call-template>
    <xsl:choose>
      <xsl:when test="../@ordered = 'true'"><xsl:value-of select="concat(count(preceding-sibling::item) + 1, '. ')"/></xsl:when>
      <xsl:otherwise>- </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="node()[not(self::list)]" mode="inline"/>
    <xsl:value-of select="$nl"/>
    <xsl:apply-templates select="list"/>
  </xsl:template>

  <xsl:template match="table">
    <xsl:if test="@title"><xsl:value-of select="concat('*', @title, '*', $nl, $nl)"/></xsl:if>
    <xsl:apply-templates select="row"/>
    <xsl:value-of select="$nl"/>
  </xsl:template>
  <xsl:template match="row">
    <xsl:text>|</xsl:text>
    <xsl:for-each select="cell">
      <xsl:text> </xsl:text><xsl:apply-templates mode="inline"><xsl:with-param name="in-table" select="true()"/></xsl:apply-templates><xsl:text> |</xsl:text>
    </xsl:for-each>
    <xsl:value-of select="$nl"/>
    <xsl:if test="@head = 'true'">
      <xsl:text>|</xsl:text>
      <xsl:for-each select="cell">---|</xsl:for-each>
      <xsl:value-of select="$nl"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="code">
    <xsl:if test="@file"><xsl:value-of select="concat('`', @file, '`', $nl)"/></xsl:if>
    <xsl:value-of select="concat('```', @lang, $nl)"/>
    <xsl:call-template name="trim-block"><xsl:with-param name="text" select="."/></xsl:call-template>
    <xsl:value-of select="concat($nl, '```', $nl, $nl)"/>
  </xsl:template>

  <xsl:template match="diagram">
    <xsl:choose>
      <xsl:when test="$diagrams = 'placeholder'">
        <xsl:text>*[</xsl:text><xsl:call-template name="label"><xsl:with-param name="key" select="'diagram'"/></xsl:call-template>
        <xsl:if test="@title"><xsl:value-of select="concat(': ', @title)"/></xsl:if>
        <xsl:value-of select="concat(']*', $nl, $nl)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('```', @kind, $nl)"/>
        <xsl:call-template name="trim-block"><xsl:with-param name="text" select="."/></xsl:call-template>
        <xsl:value-of select="concat($nl, '```', $nl)"/>
        <xsl:if test="@title"><xsl:value-of select="concat('*', @title, '*', $nl)"/></xsl:if>
        <xsl:value-of select="$nl"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- An embed is visual only: the Markdown view carries its summary. -->
  <xsl:template match="embed">
    <xsl:text>*[</xsl:text><xsl:call-template name="label"><xsl:with-param name="key" select="'figure'"/></xsl:call-template><xsl:value-of select="concat(': ', @title, ']* — ', normalize-space(@summary), $nl, $nl)"/>
  </xsl:template>

  <!-- fact, rule, limit, decision: one list item each; a run of them is one list. -->

  <xsl:template match="fact">
    <xsl:value-of select="concat('- `', translate(@method, 'adeinrstu', 'ADEINRSTU'), '` `', @source, '` · ', @verified, ' — ')"/>
    <xsl:apply-templates mode="inline"/>
    <xsl:call-template name="end-item"/>
  </xsl:template>

  <xsl:template match="rule">
    <xsl:value-of select="concat('- **', @level, '** — ')"/>
    <xsl:apply-templates mode="inline"/>
    <xsl:if test="@why"><xsl:value-of select="concat(' *(', @why, ')*')"/></xsl:if>
    <xsl:call-template name="end-item"/>
  </xsl:template>

  <xsl:template match="limit">
    <xsl:text>- </xsl:text>
    <xsl:apply-templates mode="inline"/>
    <xsl:if test="@source"><xsl:value-of select="concat(' · `', @source, '`')"/></xsl:if>
    <xsl:call-template name="end-item"/>
  </xsl:template>

  <xsl:template match="decision">
    <xsl:value-of select="concat('- **', @id, '** `', @status, '` — ')"/>
    <xsl:apply-templates select="question/node()" mode="inline"/>
    <xsl:value-of select="$nl"/>
    <xsl:for-each select="option">
      <xsl:value-of select="concat('   ', position(), '. **', @title, '**')"/>
      <xsl:if test="p">
        <xsl:text>: </xsl:text>
        <xsl:for-each select="p">
          <xsl:if test="position() > 1"><xsl:text> </xsl:text></xsl:if>
          <xsl:apply-templates mode="inline"/>
        </xsl:for-each>
      </xsl:if>
      <xsl:if test="*[not(self::p)]"><xsl:text> *</xsl:text><xsl:call-template name="label"><xsl:with-param name="key" select="'example-elsewhere'"/></xsl:call-template><xsl:text>*</xsl:text></xsl:if>
      <xsl:value-of select="$nl"/>
    </xsl:for-each>
    <xsl:for-each select="choice">
      <xsl:text>   → </xsl:text><xsl:call-template name="label"><xsl:with-param name="key" select="'choice'"/></xsl:call-template><xsl:value-of select="concat(': **', ../option[@id = current()/@option]/@title, '**')"/>
      <xsl:if test="@by or @date"><xsl:value-of select="concat(' (', @by, substring(', ', 1, 2 * number(boolean(@by and @date))), @date, ')')"/></xsl:if>
      <xsl:if test="normalize-space(.)"><xsl:text> — </xsl:text><xsl:apply-templates mode="inline"/></xsl:if>
      <xsl:value-of select="$nl"/>
    </xsl:for-each>
    <xsl:call-template name="end-list"/>
  </xsl:template>

  <xsl:template name="end-item">
    <xsl:value-of select="$nl"/>
    <xsl:call-template name="end-list"/>
  </xsl:template>

  <!-- Close the list with a blank line unless the next block is another item of it. -->
  <xsl:template name="end-list">
    <xsl:if test="not(following-sibling::*[1][self::fact or self::rule or self::limit or self::decision])">
      <xsl:value-of select="$nl"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="example">
    <xsl:text>**</xsl:text><xsl:call-template name="label"><xsl:with-param name="key" select="'example'"/></xsl:call-template><xsl:value-of select="concat(' — ', @title, '**', $nl, $nl)"/>
    <xsl:apply-templates select="*"/>
  </xsl:template>

  <xsl:template match="related/doc">
    <xsl:value-of select="concat('- `', @id, '`')"/>
    <xsl:if test="@type"><xsl:value-of select="concat(' (', @type, ')')"/></xsl:if>
    <xsl:if test="normalize-space(.)"><xsl:value-of select="concat(' — ', normalize-space(.))"/></xsl:if>
    <xsl:value-of select="$nl"/>
    <xsl:if test="not(following-sibling::doc)"><xsl:value-of select="$nl"/></xsl:if>
  </xsl:template>

  <!-- ===== inline ===== -->

  <xsl:template match="text()" mode="inline">
    <xsl:param name="in-table" select="false()"/>
    <xsl:variable name="flat" select="translate(., '&#10;&#9;&#13;', '   ')"/>
    <xsl:variable name="norm" select="normalize-space($flat)"/>
    <xsl:if test="starts-with($flat, ' ') and preceding-sibling::node()"><xsl:text> </xsl:text></xsl:if>
    <xsl:call-template name="escape">
      <xsl:with-param name="text" select="$norm"/>
      <xsl:with-param name="chars" select="concat('*_`', substring('|', 1, number($in-table)))"/>
    </xsl:call-template>
    <xsl:if test="$norm != '' and substring($flat, string-length($flat)) = ' ' and following-sibling::node()"><xsl:text> </xsl:text></xsl:if>
  </xsl:template>

  <xsl:template match="c" mode="inline">
    <xsl:choose>
      <xsl:when test="contains(., '`')"><xsl:value-of select="concat('`` ', ., ' ``')"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="concat('`', ., '`')"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="em" mode="inline"><xsl:value-of select="concat('*', normalize-space(.), '*')"/></xsl:template>
  <xsl:template match="b" mode="inline"><xsl:value-of select="concat('**', normalize-space(.), '**')"/></xsl:template>
  <xsl:template match="link" mode="inline"><xsl:value-of select="concat('[', normalize-space(.), '](', @href, ')')"/></xsl:template>
  <!-- A chat cannot follow an anchor: a reference shows its text and its target. -->
  <xsl:template match="ref" mode="inline">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:value-of select="concat(' (→ ', substring(concat(@doc, '#'), 1, string-length(@doc) + number(boolean(@doc))), @to, ')')"/>
  </xsl:template>

  <!-- ===== helpers ===== -->

  <!-- Backslash every character of $chars found in $text. -->
  <xsl:template name="escape">
    <xsl:param name="text"/>
    <xsl:param name="chars"/>
    <xsl:choose>
      <xsl:when test="$chars = ''"><xsl:value-of select="$text"/></xsl:when>
      <xsl:otherwise>
        <xsl:variable name="done">
          <xsl:call-template name="escape-one">
            <xsl:with-param name="text" select="$text"/>
            <xsl:with-param name="char" select="substring($chars, 1, 1)"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="escape">
          <xsl:with-param name="text" select="$done"/>
          <xsl:with-param name="chars" select="substring($chars, 2)"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="escape-one">
    <xsl:param name="text"/>
    <xsl:param name="char"/>
    <xsl:choose>
      <xsl:when test="contains($text, $char)">
        <xsl:value-of select="concat(substring-before($text, $char), '\', $char)"/>
        <xsl:call-template name="escape-one">
          <xsl:with-param name="text" select="substring-after($text, $char)"/>
          <xsl:with-param name="char" select="$char"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$text"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="indent">
    <xsl:param name="n"/>
    <xsl:if test="$n > 0"><xsl:text> </xsl:text><xsl:call-template name="indent"><xsl:with-param name="n" select="$n - 1"/></xsl:call-template></xsl:if>
  </xsl:template>

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

</xsl:stylesheet>
