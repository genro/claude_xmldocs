<?xml version="1.0" encoding="UTF-8"?>
<!--
  Every fixed label the views print, in English. One named template, so a
  language file (xslt/lang/<lang>.xsl, not written yet) can redefine only
  this template for documents with that lang.
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Root children that are titled parts; anything else is a block. -->
  <xsl:variable name="part-names"
    select="' purpose requires rules limits facts decisions problem current solution consequences goal risks state done next related '"/>

  <xsl:template name="label">
    <xsl:param name="key"/>
    <xsl:choose>
      <xsl:when test="$key = 'booklet'">Instruction booklet</xsl:when>
      <xsl:when test="$key = 'proposal'">Proposal</xsl:when>
      <xsl:when test="$key = 'plan'">Implementation plan</xsl:when>
      <xsl:when test="$key = 'handoff'">Handoff</xsl:when>
      <xsl:when test="$key = 'note'">Internal note</xsl:when>
      <xsl:when test="$key = 'purpose'">Purpose</xsl:when>
      <xsl:when test="$key = 'requires'">Requirements</xsl:when>
      <xsl:when test="$key = 'steps'">Steps</xsl:when>
      <xsl:when test="$key = 'rules'">Rules</xsl:when>
      <xsl:when test="$key = 'limits'">Current limits</xsl:when>
      <xsl:when test="$key = 'facts'">Verified facts</xsl:when>
      <xsl:when test="$key = 'decisions'">Decisions</xsl:when>
      <xsl:when test="$key = 'problem'">Problem</xsl:when>
      <xsl:when test="$key = 'current'">Current state</xsl:when>
      <xsl:when test="$key = 'solution'">Proposed solution</xsl:when>
      <xsl:when test="$key = 'consequences'">Consequences</xsl:when>
      <xsl:when test="$key = 'goal'">Goal</xsl:when>
      <xsl:when test="$key = 'phases'">Phases</xsl:when>
      <xsl:when test="$key = 'risks'">Risks</xsl:when>
      <xsl:when test="$key = 'state'">State</xsl:when>
      <xsl:when test="$key = 'done'">Done</xsl:when>
      <xsl:when test="$key = 'next'">Next steps</xsl:when>
      <xsl:when test="$key = 'related'">Related documents</xsl:when>
      <xsl:when test="$key = 'choice'">Choice</xsl:when>
      <xsl:when test="$key = 'done-when'">Done when</xsl:when>
      <xsl:when test="$key = 'after'">after</xsl:when>
      <xsl:when test="$key = 'needs'">needs</xsl:when>
      <xsl:when test="$key = 'diagram'">diagram</xsl:when>
      <xsl:when test="$key = 'figure'">figure</xsl:when>
      <xsl:when test="$key = 'example'">Example</xsl:when>
      <xsl:when test="$key = 'example-elsewhere'">(example in the full document)</xsl:when>
      <xsl:otherwise><xsl:value-of select="$key"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
