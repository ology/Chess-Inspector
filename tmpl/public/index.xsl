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

<div class="row">
<div class="large-12 column">
<h3>Coverage</h3>
<table border="1">
<xsl:for-each select="//response/board">
    <tr>
        <xsl:for-each select="cell">
        <td align="center" height="50" width="50">
            <xsl:if test="@white_can_move > 0">
                <xsl:attribute name="style">background: lightblue</xsl:attribute>
            </xsl:if>
            <xsl:if test="@black_can_move > 0">
                <xsl:attribute name="style">background: tan</xsl:attribute>
            </xsl:if>
            <xsl:if test="@threatened > 0">
                <xsl:attribute name="style">background: yellow</xsl:attribute>
            </xsl:if>
            <xsl:if test="@protected > 0">
                <xsl:attribute name="style">border: 3px solid green</xsl:attribute>
            </xsl:if>
            <xsl:if test="@threatened > 0 and @protected > 0">
                <xsl:attribute name="style">background: yellow; border: 3px solid green</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="@piece"/>
        </td>
        </xsl:for-each>
    </tr>
    </xsl:for-each>
</table>
</div>
</div>

<div class="row">
<div class="large-12 column">
<button name="start">|&#60;</button>
<button name="reverse">&#60;&#60;</button>
<button name="step-reverse">&#60;</button>
<button name="pause">| |</button>
<button name="step-forward">&#62;</button>
<button name="forward">&#62;&#62;</button>
<button name="end">&#62;|</button>
</div>
</div>

 </xsl:template>
</xsl:stylesheet>
