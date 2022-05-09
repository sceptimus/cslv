<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
<!--
  saxon -s:bd/articles-bib.xml -xsl:transfos/dist-simple.xsl -o:dist/articles.html
   -->

  <xsl:output method="xml" media-type="text/html" omit-xml-declaration="yes" indent="yes"/>

  <xsl:template match="/">
    <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
            <meta name="description" content="BIbliothèque ouverte" />
            <meta name="generator" content="none" />
            <title>Articles</title>
<style type="text/css" media="screen">  
span.Tag {
  display: inline-block;
  border: solid 1px gray;
  padding: 2px 4px;
  margin: 0 5px;
}
</style>            
        </head>
        <body>
          <div style="margin: 2em">
            <h1>Articles</h1>
            <p>
              Liste publiée à partir du site " <b>CSLV 85</b> " 
            </p>
            <xsl:apply-templates select="Bibliotheque/Ressources/Article">
              <xsl:sort select="(Ajout, Publication)[1]" order="descending"/>
            </xsl:apply-templates>
            <hr/>
            <p>Accès à la <a href="../index.html">page d'accueil</a></p>
          </div>
        </body>
    </html>
  </xsl:template>
  
  <xsl:template match="Article">
    <div>
      <p>
        <a href="{Page/Lien}" target="_blank"><xsl:value-of select="(TitreFR,Titre)[1]"/></a><xsl:apply-templates select="Auteurs"/><xsl:apply-templates select="Publication"/><xsl:apply-templates select="Ajout[. ne Publication or empty(Publication)]"/><xsl:apply-templates select="Source"/>
        <xsl:apply-templates select="Tag"/>
      </p>
      <blockquote>
        <xsl:copy-of select="Presentation/*"/>
      </blockquote>
    </div>
  </xsl:template>

  <xsl:template match="Auteurs"><xsl:text> par</xsl:text><xsl:apply-templates select="Nom"/>
  </xsl:template>

  <xsl:template match="Nom[empty(preceding-sibling::Nom)]"><xsl:text> </xsl:text><xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="Nom[exists(preceding-sibling::Nom) and exists(following-sibling::Nom)]"><xsl:text>, </xsl:text><xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="Nom[exists(preceding-sibling::Nom) and empty(following-sibling::Nom)]"><xsl:text> &amp; </xsl:text><xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="Publication"><xsl:text>, </xsl:text>publié le <xsl:call-template name="date"/>
  </xsl:template>

  <xsl:template match="Ajout"><xsl:text>, </xsl:text>ajouté le <xsl:call-template name="date"/>
  </xsl:template>

  <xsl:template match="Source"><xsl:text> </xsl:text>pour <i><xsl:value-of select="."/></i>
  </xsl:template>

  <xsl:template match="Tag"><xsl:text> </xsl:text><span class="Tag"><xsl:value-of select="."/></span>
  </xsl:template>

  <xsl:template name="date"><xsl:value-of select="substring(., 9, 2)"/>/<xsl:value-of select="substring(., 6, 2)"/>/<xsl:value-of select="substring(., 1, 4)"/>
  </xsl:template>

  <xsl:template name="mois">
    <xsl:param name="mois"/>
    <xsl:choose>
      <xsl:when test="$mois eq '01'">Janvier</xsl:when>
      <xsl:when test="$mois eq '02'">Février</xsl:when>
      <xsl:when test="$mois eq '03'">Mars</xsl:when>
      <xsl:when test="$mois eq '04'">Avril</xsl:when>
      <xsl:when test="$mois eq '05'">Mai</xsl:when>
      <xsl:when test="$mois eq '06'">Juin</xsl:when>
      <xsl:when test="$mois eq '07'">Juillet</xsl:when>
      <xsl:when test="$mois eq '08'">Août</xsl:when>
      <xsl:when test="$mois eq '09'">Septembre</xsl:when>
      <xsl:when test="$mois eq '10'">Octobre</xsl:when>
      <xsl:when test="$mois eq '11'">Novembre</xsl:when>
      <xsl:when test="$mois eq '12'">Décembre</xsl:when>
      <xsl:otherwise>***</xsl:otherwise>
    </xsl:choose>
  </xsl:template>    
</xsl:stylesheet>