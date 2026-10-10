<?xml version="1.0" encoding="UTF-8"?>
<!-- Internal note layout. Imports the base templates; part titles come from labels.xsl. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="base.xsl"/>

  <xsl:template match="/note">
    <xsl:call-template name="page">
      <xsl:with-param name="body"><xsl:apply-templates select="*"/></xsl:with-param>
    </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>
