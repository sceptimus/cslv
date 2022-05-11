<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
<!--
  saxon -s:bd/articles-bib.xml -xsl:transfos/dist-simple.xsl -o:dist/articles.html
  saxon -s:bd/science-bib.xml -xsl:transfos/dist-simple.xsl -o:dist/science.html
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
.top {
  float: right;
  margin-right: 20px;
}
a {
  text-decoration: none;
  color: rgb(0, 0, 238);
}  
a:visited {
  color: rgb(0, 0, 238);
}  
span.Tag {
  display: inline-block;
  border: solid 1px gray;
  padding: 2px 4px;
  margin: 0 5px;
}
a.rubrique:last-of-type::after {
  content: ''; 
}
a.rubrique::after {
  content: ' | '; 
}
img.pdf {
 width: 32px;
 vertical-align:text-bottom;
}
span.VO {
  color: white;
  background: black;
  padding: 2px 3px;
  font-size: 0.75em;
  font-family: "Trebuchet MS", Verdana, sans-serif;
  font-weight: bold;
}
</style>            
        </head>
        <body>
          <div id="top" style="margin: 2em">
            <h1>Articles</h1>
            <p>
              Liste publiée à partir du site " <b>CSLV 85</b> " - Accès à la <a href="../index.html">page d'accueil</a>
            </p>
            <p>
              <b>Rubrique(s)</b> :  
              <xsl:for-each-group select="Bibliotheque/Ressources/Article" group-by="Rubrique">
                  <xsl:sort select="current-grouping-key()"/>
                  <a class="rubrique" href="#{current-grouping-key()}"><xsl:value-of select="current-grouping-key()"/></a>               </xsl:for-each-group>
            </p>            
            <!-- <xsl:apply-templates select="Bibliotheque/Ressources/Article"> -->
            <xsl:for-each-group select="Bibliotheque/Ressources/Article" group-by="Rubrique">
              <xsl:sort select="current-grouping-key()"/>
              <div id="{current-grouping-key()}">
                <h2><xsl:value-of select="current-grouping-key()"/><a class="top" href="#top" title="Haut de page">​ᐃ​</a></h2>
                <xsl:apply-templates select="current-group()">
                  <xsl:sort select="(Ajout, Publication)[1]" order="descending"/>
                </xsl:apply-templates>                
              </div>
            </xsl:for-each-group>
            <!-- </xsl:apply-templates> -->
            <hr/>
            <p>Accès à la <a href="../index.html">page d'accueil</a></p>
          </div>
        </body>
    </html>
  </xsl:template>
  
  <xsl:template match="Article">
    <div>
      <p>
        <a href="{Page/Lien}" target="_blank"><xsl:value-of select="(TitreFR,Titre)[1]"/></a><xsl:apply-templates select="TitreFR[../Titre]"/><xsl:apply-templates select="PDF/Lien[1]" mode="PDF"/><xsl:apply-templates select="Auteurs"/><xsl:apply-templates select="Publication"/><xsl:apply-templates select="Ajout[empty(../Publication)]"/><xsl:apply-templates select="Source"/>
        <xsl:apply-templates select="Tag"/>
      </p>
      <blockquote>
        <xsl:copy-of select="Presentation/*"/>
      </blockquote>
    </div>
  </xsl:template>

  <xsl:template match="TitreFR"><xsl:text> </xsl:text><span class="VO" title="{../Titre}">VO</span>
  </xsl:template>

  <xsl:template match="Auteurs"><xsl:text> par</xsl:text><xsl:apply-templates select="Nom"/>
  </xsl:template>

  <xsl:template match="Nom[empty(preceding-sibling::Nom)]"><xsl:text> </xsl:text><xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="Nom[exists(preceding-sibling::Nom) and exists(following-sibling::Nom)]"><xsl:text>, </xsl:text><xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="Nom[exists(preceding-sibling::Nom) and empty(following-sibling::Nom)]"><xsl:text> &amp; </xsl:text><xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="Lien" mode="PDF"><a href="{.}"><img class="pdf" src="img/pdf.png"/></a>
  </xsl:template>

  <xsl:template match="Publication"><xsl:text>, </xsl:text>publié le <xsl:call-template name="date"/>
  </xsl:template>

  <xsl:template match="Ajout"><xsl:text>, </xsl:text>ajouté le <xsl:call-template name="date"/>
  </xsl:template>

  <xsl:template match="Source"><xsl:text> </xsl:text>pour <i><xsl:value-of select="."/></i>
  </xsl:template>

  <xsl:template match="Tag"><xsl:text> </xsl:text><span class="Tag"><xsl:value-of select="."/></span>
  </xsl:template>

  <xsl:template name="date"><xsl:value-of select="replace(substring(., 9, 2), '^0', '')"/><xsl:text> </xsl:text><xsl:call-template name="mois"><xsl:with-param name="mois"><xsl:value-of select="substring(., 6, 2)"/></xsl:with-param></xsl:call-template><xsl:text> </xsl:text><xsl:value-of select="substring(., 1, 4)"/>
  </xsl:template>

  <xsl:template name="mois">
    <xsl:param name="mois"/>
    <xsl:choose>
      <xsl:when test="$mois eq '01'">janv.</xsl:when>
      <xsl:when test="$mois eq '02'">févr.</xsl:when>
      <xsl:when test="$mois eq '03'">mars</xsl:when>
      <xsl:when test="$mois eq '04'">avr.</xsl:when>
      <xsl:when test="$mois eq '05'">mai</xsl:when>
      <xsl:when test="$mois eq '06'">juin</xsl:when>
      <xsl:when test="$mois eq '07'">juill.</xsl:when>
      <xsl:when test="$mois eq '08'">août</xsl:when>
      <xsl:when test="$mois eq '09'">sept.</xsl:when>
      <xsl:when test="$mois eq '10'">oct.</xsl:when>
      <xsl:when test="$mois eq '11'">nov.</xsl:when>
      <xsl:when test="$mois eq '12'">déc.</xsl:when>
      <xsl:otherwise>***</xsl:otherwise>
    </xsl:choose>
  </xsl:template>    
</xsl:stylesheet>