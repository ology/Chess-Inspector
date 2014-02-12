<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" xmlns:date="http://exslt.org/dates-and-times" xmlns:cham="urn:cham">
 <xsl:output method="html" omit-xml-declaration="no" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" indent="yes" />
 <xsl:template name="outer_shell">
  <xsl:param name="content_nodeset"></xsl:param>

  <html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="css/foundation.css" />
    <script src="js/modernizr.js"></script>
  </head>
   <body>

    <div class="row">
    <div class="large-12 columns">
    <xsl:copy-of select="exsl:node-set($content_nodeset)"></xsl:copy-of>
    </div>
    </div>

    <script src="js/jquery.js"></script>
    <script src="js/foundation.min.js"></script>
    <script>$(document).foundation();</script>
    <script>
        $(document).ready(function() {
            $("td").click(function( event ) {
                color = $(this).css("color");
                if ( color == "rgb(34, 34, 34)" || color == "rgb(0, 0, 0)" ) {
                    $(this).css("color", "red");
                }
                else {
                    $(this).css("color", "black");
                }
            });
        });
    </script>
   </body>
  </html>

 </xsl:template>
</xsl:stylesheet>
