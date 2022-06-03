<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml">

  <xsl:output method="xml" media-type="text/html" omit-xml-declaration="yes" indent="yes"/>
  
  <xsl:template match="/">
    <html>
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
      <meta name="description" content="Comité Santé Liberté Vendée 85 liste de victimes dans la presse"/>
      <title><xsl:value-of select="Titre"></title>
      <head>
<style type="text/css">
  body {
  margin: 20px;
  }
  div.article {
    margin: 0 0 10px
  }
  span.auteur {
    font-style: italic;
    color: orange;
  }
  span.tag {
    display: inline-block;
    border: solid 1px gray;
    padding: 2px;
    margin: 0 10px;
  }
  span.text {
    margin-left: 40px;
    color: #444;
  } 
</style>
<script type="text/javascript">
var ALLFILTERS = {
  'titre' : '',
  'auteur' : '',
  'tag' : ''
  };
  
function matchFilter(div, keys) {
  var text, txtValue, k, m, filter;
  m = true;
  
  for (var i = 0; i < keys.length; i++) {
    k = keys[i];
    filter = ALLFILTERS[k];
    text = cur.getElementsByClassName(k)[0];
    window.console.log('check ' + k + ' =' + filter);
    if ((filter.length > 0) && text) {
      txtValue = titre.textContent || titre.innerText;
      // todo iterate + diacritics
      if ((txtValue.toUpperCase()).indexOf(filter) === -1) {
        m = false;
      }
    }
  }
}
  
function filterOn(inputobject, classname) {
  var input, filter, div, cur, titre, i, txtValue, count, restrict;
  input = inputobject;
  filter = input.value.toUpperCase();
  div = document.getElementsByClassName("article");
  count = 0;
  restrict = filter.length > ALLFILTERS[classname].length;
  ALLFILTERS[classname] = filter;
   
   // Loop through all rows, and hide those who don't match the search query
   for (i = 0; i != div.length; i++) {
     cur = div[i];
     if (matchFilter(cur, ['titre', 'auteur', 'tag'])) {
       cur.style.display = "";
       ++count;
     } else {
       cur.style.display = "none";
     }
     <!-- titre = cur.getElementsByClassName(classname)[0];
     if (titre) {
       txtValue = titre.textContent || titre.innerText;
       // todo iterate + diacritics
       if ((txtValue.toUpperCase()).indexOf(filter) != -1) {
         cur.style.display = "";
         ++count;
       } else {
         cur.style.display = "none";
       }
     } -->
   }
   
   counter = document.getElementById("total");
   counter.textContent = count;
}
</script>
      </head>
      <body>
          <h1><xsl:value-of select="Titre"></h1>        
          <p>Titre: <input id="filtre-titre" onkeyup="javascript:filterOn(this, 'titre')" type="text"/> Auteur: <input onkeyup="javascript:filterOn(this, 'auteur')" type="text"/> Mot-clef: <input onkeyup="javascript:filterOn(this, 'tag')" type="text"/> Total: <span id="total"><xsl:value-of select="count(Ressources//Article)"/></span></p>
          <!-- <xsl:apply-templates select="Ressources//Article">
          </xsl:apply-templates> -->
          <xsl:for-each-group select="Ressources//Article" group-by="substring((Publication, Ajout)[1], 1, 4)">
            <xsl:sort select="substring(current-grouping-key(), 1, 4)" order="descending"/>
            <h2>
              <xsl:variable name="annee" select="substring(current-grouping-key(), 1, 4)"/>
              <xsl:choose>
                <xsl:when test="string-length($annee) = 0">X</xsl:when>
                <xsl:otherwise><xsl:value-of select="$annee"/></xsl:otherwise>
              </xsl:choose>
            </h2>
            <xsl:for-each select="current-group()">
              <xsl:apply-templates select="."/>
            </xsl:for-each>
          </xsl:for-each-group>          
      </body>
    </html>
  </xsl:template>

  <xsl:template match="Article">
    <div class="article">
      <p>
        <xsl:value-of select="position()"/>. 
        <span class="titre"><xsl:value-of select="Titre"/></span> par <span class="auteur"><xsl:value-of select="Auteur"/></span><xsl:apply-templates select="Tag"/><br/>
        <span class="text"><xsl:value-of select="string(Presentation)"/></span>
      </p>
    </div>
  </xsl:template>

  <xsl:template match="Tag"><span class="tag"><xsl:value-of select="."/></span>
  </xsl:template>

</xsl:stylesheet>