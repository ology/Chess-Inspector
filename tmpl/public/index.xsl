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

<xsl:variable name="fen"><xsl:value-of select="//response/game/@fen"/></xsl:variable>
<xsl:variable name="pgn"><xsl:value-of select="//response/game/@pgn"/></xsl:variable>
<xsl:variable name="reverse"><xsl:value-of select="//response/game/@reverse"/></xsl:variable>
<xsl:variable name="forward"><xsl:value-of select="//response/game/@forward"/></xsl:variable>

<div class="row">

<div class="large-6 column">
<h3>Chess::Inspector</h3>
<table>
<xsl:for-each select="//response/board">
    <tr>
        <xsl:for-each select="cell">
        <xsl:variable name="rowcol"><xsl:value-of select="@row"/><xsl:value-of select="@col"/></xsl:variable>
        <td id="{$rowcol}" align="center" height="55" width="55">
            <xsl:if test="//response/game/@to_move > 0">
                <xsl:if test="@black_can_move > 0">
                    <xsl:attribute name="style">background: tan</xsl:attribute>
                </xsl:if>
                <xsl:if test="@white_can_move > 0">
                    <xsl:attribute name="style">background: lightblue</xsl:attribute>
                </xsl:if>
                <xsl:if test="@white_can_move > 0 and @black_can_move > 0">
                    <xsl:attribute name="style">background: lightblue; border: 5px solid tan</xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:if test="//response/game/@to_move = 0">
                <xsl:if test="@white_can_move > 0">
                    <xsl:attribute name="style">background: lightblue</xsl:attribute>
                </xsl:if>
                <xsl:if test="@black_can_move > 0">
                    <xsl:attribute name="style">background: tan</xsl:attribute>
                </xsl:if>
                <xsl:if test="@black_can_move > 0 and @white_can_move > 0">
                    <xsl:attribute name="style">background: tan; border: 5px solid lightblue</xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:if test="@threatened > 0">
                <xsl:attribute name="style">background: yellow</xsl:attribute>
            </xsl:if>
            <xsl:if test="@protected > 0">
                <xsl:attribute name="style">border: <xsl:value-of select="@protected"/>px solid green</xsl:attribute>
            </xsl:if>
            <xsl:if test="@threatened > 0 and @protected > 0">
                <xsl:attribute name="style">background: yellow; border: <xsl:value-of select="@protected"/>px solid green</xsl:attribute>
            </xsl:if>
            <a href="/?position={$rowcol};pgn={$pgn};move={$forward - 1}">
            <xsl:choose>
              <xsl:when test="$rowcol = @position">
                <xsl:attribute name="style">color: red; font-size: 200%; text-decoration: none</xsl:attribute>
                <xsl:if test="@piece">
                <xsl:value-of disable-output-escaping="yes" select="@piece"/>
                </xsl:if>
                <xsl:if test="@piece = ''">X</xsl:if>
              </xsl:when>
              <xsl:when test="@piece = ''">
                <xsl:attribute name="style">color: blue; font-size: 200%; text-decoration: none</xsl:attribute>
                X
              </xsl:when>
              <xsl:when test="@piece">
                <xsl:attribute name="style">color: black; font-size: 200%; text-decoration: none</xsl:attribute>
                <xsl:value-of disable-output-escaping="yes" select="@piece"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="style">color: gray; font-size: 200%; text-decoration: none</xsl:attribute>
                ?
              </xsl:otherwise>
            </xsl:choose>
            </a>
        </td>
        </xsl:for-each>
    </tr>
    </xsl:for-each>

    <tr>
    <td colspan="8" align="center">
      <a href="/?pgn={$pgn};move=0" class="tiny button" title="Start">|&#60;</a>
      <a href="/?pgn={$pgn};move={$reverse}" class="tiny button" title="Step back">&#60;</a>
      <a href="/?pgn={$pgn};move={$forward}" class="tiny button" title="Step forward">&#62;</a>
      <a href="/?pgn={$pgn};move=-1" class="tiny button" title="End">&#62;|</a>
    </td>
    </tr>

</table>

</div>

<div class="large-3 column">
  <p/>
  <h3>
  <xsl:if test="//response/game/@to_move = 0">
    White
  </xsl:if>
  <xsl:if test="//response/game/@to_move = 128">
    White to move
  </xsl:if>
  </h3>
  <div class="panel">
    <p>Player: <xsl:value-of select="//response/white/@name"/></p>
    <p>Moves made: <xsl:value-of select="//response/white/@moves_made"/></p>
    <p style="background: lightblue; padding: 5px">Can move to: <xsl:value-of select="//response/white/@can_move"/>
    cell<xsl:if test="//response/white/@can_move != 1">s</xsl:if></p>
    <p style="background: yellow; padding: 5px">Threaten: <xsl:value-of select="//response/white/@threaten"/>
    time<xsl:if test="//response/white/@threaten != 1">s</xsl:if></p>
    <p style="border: 3px solid green; padding: 5px">Protect: <xsl:value-of select="//response/white/@protect"/>
    time<xsl:if test="//response/white/@protect != 1">s</xsl:if></p>
  </div>
</div>
<div class="large-3 column">
  <p/>
  <h3>
  <xsl:if test="//response/game/@to_move = 128">
    Black
  </xsl:if>
  <xsl:if test="//response/game/@to_move = 0">
    Black to move
  </xsl:if>
  </h3>
  <div class="panel">
    <p>Player: <xsl:value-of select="//response/black/@name"/></p>
    <p>Moves made: <xsl:value-of select="//response/black/@moves_made"/></p>
    <p style="background: tan; padding: 5px">Can move to: <xsl:value-of select="//response/black/@can_move"/>
    cell<xsl:if test="//response/black/@can_move != 1">s</xsl:if></p>
    <p style="background: yellow; padding: 5px">Threaten: <xsl:value-of select="//response/black/@threaten"/>
    time<xsl:if test="//response/black/@threaten != 1">s</xsl:if></p>
    <p style="border: 3px solid green; padding: 5px">Protect: <xsl:value-of select="//response/black/@protect"/>
    time<xsl:if test="//response/black/@protect != 1">s</xsl:if></p>
  </div>
</div>

<div class="large-6 column">
  <form>
  <select name="pgn">
    <option value="">Select a game</option>
    <xsl:for-each select="//response/games">
        <xsl:variable name="name"><xsl:value-of select="@name"/></xsl:variable>
    <option value="{$name}">
        <xsl:if test="@selected = $name">
            <xsl:attribute name="selected" value="1"/>
        </xsl:if>
        <xsl:value-of select="$name"/>
    </option>
    </xsl:for-each>
  </select>
  <input type="text" name="fen" value="{$fen}"/>
  <input type="submit" value="Refresh" class="tiny button right"/>
  </form>
</div>

</div>

 </xsl:template>
</xsl:stylesheet>
