<?xml version="1.0" encoding="UTF-8"?>
<!-- Implementation plan layout. Imports the base templates; part titles come from labels.xsl. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="base.xsl"/>

  <xsl:template match="/plan">
    <xsl:call-template name="page">
      <xsl:with-param name="body">
        <xsl:apply-templates select="goal | current | decisions"/>
        <section class="part phases">
          <h2><xsl:call-template name="label"><xsl:with-param name="key" select="'phases'"/></xsl:call-template></h2>
          <xsl:apply-templates select="phase"/>
        </section>
        <xsl:apply-templates select="risks | related"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="phase">
    <section class="section phase" id="{@id}">
      <h3><span class="step-num"><xsl:value-of select="count(preceding-sibling::phase) + 1"/>.</span><xsl:value-of select="@title"/></h3>
      <div class="box-head">
        <span class="tag tag-{@status}"><xsl:value-of select="@status"/><xsl:if test="not(@status)">todo</xsl:if></span>
        <code class="source"><xsl:value-of select="@repo"/></code>
        <xsl:if test="@after"><span class="muted"><xsl:call-template name="label"><xsl:with-param name="key" select="'after'"/></xsl:call-template>: <xsl:value-of select="@after"/></span></xsl:if>
        <xsl:if test="@needs"><span class="muted"><xsl:call-template name="label"><xsl:with-param name="key" select="'needs'"/></xsl:call-template>: <xsl:value-of select="@needs"/></span></xsl:if>
      </div>
      <xsl:apply-templates select="*[not(self::done)]"/>
      <div class="box done"><b><xsl:call-template name="label"><xsl:with-param name="key" select="'done-when'"/></xsl:call-template>: </b><xsl:apply-templates select="done/node()"/></div>
    </section>
  </xsl:template>
</xsl:stylesheet>
