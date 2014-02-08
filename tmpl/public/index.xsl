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
<div class="large-6 column">
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

<div class="large-3 column">
<h3>
White<xsl:if test="//response/game/@to_move = 128"> to move</xsl:if>
</h3>
<div class="panel">
<p>Moves:</p>
<p>Threatens:</p>
<p>Protects:</p>
</div>
</div>

<div class="large-3 column">
<h3>
Black<xsl:if test="//response/game/@to_move = 0"> to move</xsl:if>
</h3>
<div class="panel">
<p>Moves:</p>
<p>Threatens:</p>
<p>Protects:</p>
</div>
</div>

<div class="large-6 column">
<form>
<xsl:variable name="fen" select="//response/game/@fen"/>
<label>FEN:</label> <input type="text" name="fen" value="{$fen}"/>
<input type="submit" value="Submit" class="tiny button right"/>
</form>
</div>
<div class="large-6 column">
<xsl:if test="//response/game/@pgn">
    <p>Current = <xsl:value-of select="//response/game/@pgn"/></p>
</xsl:if>
<label>PGN:</label> <input type="file" name="pgn"/>
</div>

</div>

<div class="row">

<div class="large-6 column">
<button class="tiny" title="Start">|&#60;</button>
<button class="tiny" title="Reverse">&#60;&#60;</button>
<button class="tiny" title="Step-reverse">&#60;</button>
<button class="tiny" title="Pause">| |</button>
<button class="tiny" title="Step-forward">&#62;</button>
<button class="tiny" title="Forward">&#62;&#62;</button>
<button class="tiny" title="End">&#62;|</button>
</div>

</div>

 </xsl:template>
</xsl:stylesheet>
