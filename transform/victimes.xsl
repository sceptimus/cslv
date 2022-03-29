<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml">

  <xsl:output method="xml" media-type="text/html" omit-xml-declaration="yes" indent="yes"/>

  <xsl:template match="/">
    <html>
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
      <meta name="description" content="Comité Santé Liberté Vendée 85 liste de victimes dans la presse"/>
      <title>Articles de presse, quelle est la cause ?</title>
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
        <table class="victimes">
          <tr>
            <th>Nature</th>
            <th>Date de parution</th>
            <th>Titre de l'article de presse</th>
            <th>Ville</th>
            <th>Age</th>
          </tr>
          <xsl:apply-templates select="Victimes/Victime[empty(@Afficher) or @Afficher eq 'oui']">
            <xsl:sort select="Article/Publication[1]" order="descending"/>
          </xsl:apply-templates>
        </table>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="Victime">
    <tr>
      <td><xsl:value-of select="Evolution/text()"/></td>      
      <xsl:apply-templates select="Article[1]"/>
      <td><xsl:value-of select="Ville/text()"/> (<xsl:value-of select="Departement/text()"/>)</td>
      <td><xsl:apply-templates select="Age"/></td>
    </tr>
  </xsl:template>
  
  <xsl:template match="Article">
    <td><xsl:value-of select="concat(substring(Publication, 9, 2), '/', substring(Publication, 6, 2), '/', substring(Publication, 1, 4))"/></td>
    <td>
      <a href="{Lien/Base}{Lien/Chemin}"><xsl:value-of select="Titre/text()"/></a>
      <xsl:apply-templates select="./following-sibling::Article" mode="extra"/>
    </td>
  </xsl:template>
  
  <xsl:template match="Article" mode="extra">
    <xsl:text> </xsl:text>(voir aussi <a href="{Lien/Base}{Lien/Chemin}">ici</a>)
  </xsl:template>
  
  <xsl:template match="Age"><xsl:value-of select="."/> ans
  </xsl:template>

</xsl:stylesheet>