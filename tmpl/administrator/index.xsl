<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" xmlns:date="http://exslt.org/dates-and-times" xmlns:cham="urn:cham">
 <xsl:import href="class://outer_shell.xsl"></xsl:import>
 <xsl:output method="html" omit-xml-declaration="no" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" indent="yes" />
 <xsl:template match="/">
  <xsl:call-template name="outer_shell">
   <xsl:with-param name="content_nodeset">
    <xsl:apply-templates select="/" mode="local"></xsl:apply-templates>
   </xsl:with-param>
  </xsl:call-template>
 </xsl:template>
 <xsl:template match="/" mode="local">
  <p>It worked</p>
 </xsl:template>
</xsl:stylesheet>
