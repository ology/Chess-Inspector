<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" xmlns:date="http://exslt.org/dates-and-times" xmlns:cham="urn:cham">
 <xsl:output method="html" omit-xml-declaration="no" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" indent="yes" />
 <xsl:template name="outer_shell">
  <xsl:param name="content_nodeset"></xsl:param>
  <html>
   <body>
    <xsl:copy-of select="exsl:node-set($content_nodeset)"></xsl:copy-of>
   </body>
  </html>
 </xsl:template>
</xsl:stylesheet>
