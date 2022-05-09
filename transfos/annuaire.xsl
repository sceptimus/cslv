<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml">

  <xsl:output method="xml" media-type="text/html" omit-xml-declaration="yes" indent="yes"/>

  <xsl:template match="/">
    <html>
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
      <title>Annuaire</title>
      <head>
<style type="text/css">
  body {
  margin: 20px;
  }
  table {
    font-size: 16px;
    font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
    border-collapse: collapse;
    border-spacing: 0;
    width: 100%;
  }
  td, th {
    border: 1px solid #ddd;
    text-align: left;
    padding: 8px;
  }
  tr:nth-child(odd) {
    background-color: #f2f2f2
  }
  th {
    padding-top: 11px;
    padding-bottom: 11px;
    background-color: #04AA6D;
    color: white;
  }
</style>        
      </head>
      <body>
        <table>
          <xsl:apply-templates select="annuaire/federation[acronyme ne '']">
            <!-- <xsl:sort select="acronyme" order="descending"/> -->
          </xsl:apply-templates>
        </table>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="federation">
    <tr>
      <td>
        <div>
            <p>
              <xsl:value-of select="acronyme"/><br/>
              <xsl:value-of select="addresse/rue"/><br/>
              <xsl:value-of select="addresse/code"/><xsl:text> </xsl:text><xsl:value-of select="addresse/ville"/>
            </p>
            <p>
              <xsl:if test="email">
                écrire : <a href="mailto:{email}"><xsl:value-of select="email"/></a>,<xsl:text> </xsl:text>
              </xsl:if>
              <xsl:if test="siteweb">
                visiter : <a href="{siteweb}"><xsl:value-of select="siteweb"/></a>
              </xsl:if>
            </p>
        </div>
      </td>      
    </tr>
  </xsl:template>

</xsl:stylesheet>