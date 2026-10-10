<?xml version="1.0" encoding="UTF-8"?>
<!-- Instruction booklet layout. Imports the base templates; part titles come from labels.xsl. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="base.xsl"/>

  <xsl:template match="/booklet">
    <xsl:call-template name="page">
      <xsl:with-param name="body">
        <xsl:apply-templates select="purpose | requires"/>
        <section class="part steps">
          <h2><xsl:call-template name="label"><xsl:with-param name="key" select="'steps'"/></xsl:call-template></h2>
          <xsl:apply-templates select="step"/>
        </section>
        <xsl:apply-templates select="rules | limits | facts | decisions | related"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="step">
    <section class="section step">
      <xsl:if test="@id"><xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute></xsl:if>
      <h3><span class="step-num"><xsl:value-of select="count(preceding-sibling::step) + 1"/>.</span><xsl:value-of select="@title"/></h3>
      <xsl:apply-templates/>
    </section>
  </xsl:template>
</xsl:stylesheet>
