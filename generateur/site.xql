xquery version "3.1";

declare option exist:serialize "method=xml media-type=application/xml indent=yes";

declare variable $base := '/Users/stephane/Comptes/perso/virus/sites/comitesantelibertevendee.fr/www';

declare function local:date( $date ) {
    let $year := substring(string(current-dateTime()), 1, 4)
    return 
        string-join(
            (
            substring($date, 9, 2),
            substring($date, 6, 2),
            if (starts-with($date, $year)) then () else substring($date, 1, 4)
            ), 
            '/'
        )
};

declare function local:image ( $image ) {
  <div class="block border">
      <center>
          <img src="{$image/Source}" width="{$image/Largeur}"/>
      </center>
  </div>  
};


declare function local:films ( $name, $genre ) {
  <ul>
    {
    let $films := util:eval(file:read($base || '/bd/' || 'films' || '.xml'))
    return    
      for $f in $films//Film[Genre eq $genre]
      return
          <li>
            <a href="{$f/Lien/text()}">{$f/Titre/text()}</a>
            {
            if ($f/Commentaire)
              then ': ' ||  $f/Commentaire/text()
              else ()
            }
          </li>
    }
    </ul>
};
  
(:~
 : Filtrage pour insertion lien blog dans menu vers dernière entrée du blog
 : 
 :)  
declare function local:lien-pour-menu ( $page, $sitemap ) {
  if ($page/@File eq 'blog') then
    replace($sitemap/Contenu/Page[Id eq 'blog']/Billet[last()]/@File, '.xml', '.html')
  else
    $page/@File || '.html'
};
  
(:~
 : Création du menu du site à insérer sur chaque page
 : 
 :)
declare function local:menu( $name ) {
  let $sitemap := util:eval(file:read($base || '/gabarits/' || 'site.xml'))
  let $menu := $sitemap/Menu
  return
    <div id="menu" class="noprint">
      <div id="buttons">
        {
          if ($name = $menu/Groupe/Page/@File) then
            for $p in $menu/(Page|Groupe)
            return
              if (local-name($p) eq 'Groupe') then (
                  <div class="off rubrique {$p/@Tag} ouvre top" onclick="javascript:ouvrir('{$p/@Tag}')"><p>{$p/Nom/text()}</p></div>,
                  <div class="rubrique {$p/@Tag} sub"><p><a onclick="javascript:fermer('{$p/@Tag}')">&lt;&lt;</a></p></div>,
                  for $sub in $p/Page
                  return
                    if ($sub/@File eq $name)
                      then <div class="rubrique on {$p/@Tag} sub"><p>{$sub/text()}</p></div>
                      else <div class="rubrique {$p/@Tag} sub"><p><a href="{$sub/@File}.html">{$sub/text()}</a></p></div>
                  )
              else if ($p/@File eq $name)
                  then <div class="off rubrique on top"><p>{$p/text()}</p></div>
                  else <div class="off rubrique top"><p><a href="{local:lien-pour-menu($p, $sitemap)}">{$p/text()}</a></p></div>          
          else
            for $p in $menu/(Page|Groupe)
            return
              if (local-name($p) eq 'Groupe') then (
                  <div class="rubrique {$p/@Tag} ouvre top" onclick="javascript:ouvrir('{$p/@Tag}')"><p>{$p/Nom/text()}</p></div>,
                  <div class="off rubrique {$p/@Tag} sub"><p><a onclick="javascript:fermer('{$p/@Tag}')">&lt;&lt;</a></p></div>,
                  for $sub in $p/Page
                  return
                    if ($sub/@File eq $name)
                      then <div class="off rubrique on {$p/@Tag} sub"><p>{$sub/text()}</p></div>
                      else <div class="off rubrique {$p/@Tag} sub"><p><a href="{$sub/@File}.html">{$sub/text()}</a></p></div>
                  )
              else if ($p/@File eq $name)
                  then <div class="rubrique on top"><p>{$p/text()}</p></div>
                  else <div class="rubrique top"><p><a href="{local:lien-pour-menu($p, $sitemap)}">{$p/text()}</a></p></div>
        }
      </div>
    </div>
};

(:~
 : Conversion <Videotheque> vers HTML
 : 
 :)
declare function local:videos ( $file ) {
    let $rubriques := util:eval(file:read($base || '/gabarits/' || 'site.xml'))/Contenu/Page[Id eq replace($file, '.xml', '')]/Rubriques  
    let $input := util:eval(file:read($base || '/bd/' || $file))
    return
        for $r in $rubriques/Rubrique
        return
            <div class="block border">
                <h2>{ $r/Titre/text() }</h2>
                {
                if ($r/Presentation) then
                    <blockquote>{ $r/Presentation/text() }</blockquote>
                else
                    ()
                }
                <ul>    
                    {
                    for $v in $input//Video[@Afficher eq 'oui'][Tag = $r/Tag]
                    return
                        <li>
                            <a href="{$v/Lien}">
                                {
                                if ($v/Lien/@Censure eq "oui") then
                                    (<del>{ $v/Titre/text() }</del>, ' (déjà censurée !)')
                                else
                                    $v/Titre/text()
                                }
                            </a>
                            <sup>
                                {
                                '(' ||
                                string-join((
                                    $v/Duree/text(),
                                    $v/Langue,
                                    if ($v/SousTitre eq 'activer') then 
                                        'sous-titrable'
                                    else if ($v/SousTitre) then 
                                        'sous-titrée'
                                    else
                                        (),
                                    concat('ajouté le ', $v/Ajout))
                                    , ', ') || ')'
                                }
                            </sup>: 
                            { $v/Presentation/text()}
                        </li>
                    }
                </ul>
            </div>
};

(:~
 : Conversion <Annuaire> vers HTML
 : 
 :)
declare function local:annuaire ( $file ) {
    let $rubriques := util:eval(file:read($base || '/gabarits/' || 'site.xml'))/Contenu/Page[Id eq replace($file, '.xml', '')]/Rubriques
    let $input := util:eval(file:read($base || '/bd/' || $file))
    return
        for $r in $rubriques/Rubrique
        return
            if ($r/Image) then (: image intercalaire :)
              local:image($r/Image)
            else
              <div class="block border">
                <h2>{ $r/Titre/text() }</h2>
                {
                if ($r/Presentation) then
                    <blockquote>{ $r/Presentation/(*|text()) }</blockquote>
                else
                    (),                      
                if ($r/Rubrique) then (: nested Rubrique :)
                  for $sub in $r/Rubrique return local:rubrique($r/Tag, $sub, $input)
                else
                  local:rubrique((), $r, $input) (: a flat Rubrique :)
                }
              </div>
};

(:~
 : Render a Rubrique (no iteration inside nested Rubrique)
 : 
 :)
declare function local:rubrique ( $root-tag as element()*, $r, $database ) {
  let $entries := 
    for $entry in $database//Groupe[empty($root-tag) or Tag = $root-tag][empty(@Afficher) or @Afficher eq 'oui']
    where (empty($r/Tag) or $entry/Tag = $r/Tag)
          and
          (
          empty($r/Departement)
          or (exists($r/Departement/Inclus) and $entry/Departement = $r/Departement/Inclus)
          or (exists($r/Departement/Exclu) and not($entry/Departement = $r/Departement/Exclu))
          )
    return
      $entry
  return (
    if ($root-tag)
      then <h3>{$r/Titre/text()}</h3>
      else (),
    if ($entries) then
      <ul>
        {
        for $e in $entries
        return
          <li>
            <a href="{$e/Lien}">{ $e/Nom/text() }</a>
            {
            (: should be a <p> or simple text() :)
            if ($e/Presentation) then (
              ': ',
              $e/Presentation/(*|text())
              )
            else 
              ()
            } 
          </li>
        }
      </ul>      
    else
      ()
    )
};

declare function local:biblio ( $file ) {
    let $rubriques := util:eval(file:read($base || '/gabarits/' || 'site.xml'))/Contenu/Page[Id eq replace($file, '.xml', '')]/Rubriques
    let $input := util:eval(file:read($base || '/bd/' || $file))
    return
        for $r in $rubriques/Rubrique
        return
            <div class="block border">
                <h2>{ $r/Titre/text() }</h2>
                {
                if ($r/Presentation) then
                    <blockquote>{ $r/Presentation/* }</blockquote>
                else
                    ()
                }
                <ul>    
                    {
                    for $i in $input//Article[@Afficher eq 'oui'][Tag = $r/Tag]
                    order by $i/Ajout descending
                    return
                        <li>
                            <a href="{$i/Lien}">{ $i/Titre/text() }</a>
                            <span> par { $i/Auteur/text() }</span>
                            <p>{if ($i/Commentaire) then (replace($i/Commentaire, '\.$', '') || '. Publié') else 'publié' } le { local:date($i/Parution) } (ajouté le { local:date($i/Ajout) })</p>
                        </li>
                    }
                </ul>
            </div>            
};

(:~
 : Génère l'index du blog
 : 
 :)
declare function local:blog-index ( $billet, $gabarit ) {
  let $contenu := util:eval(file:read($base || '/gabarits/' || 'site.xml'))/Contenu
  return
    <ul class="blog">
      {
      for $cur in $contenu/Page[Id eq $gabarit]/Billet
      return
        if (replace($cur/@File, '.xml', '') eq $billet/Fichier) then
          <li class="cur">&#9734; <b>{$billet/Titre/text()}</b></li>
        else
          let $autre := util:eval(file:read($base || '/blog/' || $cur/@File))
          return
            <li><a href="{$autre/Fichier || '.html'}">{ $autre/Titre/text() }</a> ({local:date($autre/Date)})</li>
      }
    </ul>  
};

(:~
 : Génère 1 fichier par page de blog
 : 
 :)
declare function local:blog ( $gabarit ) {
  let $page := file:read($base || '/gabarits/' || $gabarit || '.xml')  
  let $billets := util:eval(file:read($base || '/gabarits/' || 'site.xml'))/Contenu/Page[Id eq $gabarit]/Billet
  return
    for $b in $billets
    let $file := $b/@File
    let $billet := util:eval(file:read($base || '/blog/' || $file))
    return
      <page name="{$file}">{ file:serialize(util:eval($page), $base || '/' || replace($file, '.xml', '.html'), ()) }</page>
};

declare function local:render( $gabarit, $in ) {
    if ($gabarit eq 'blog') then
      local:blog ($gabarit)
    else
      let $page := file:read($base || '/gabarits/' || $gabarit || '.xml')
      return
          file:serialize(util:eval($page), $base || '/' || $gabarit || '.html', ())
};

let $ts := current-dateTime()
let $in := map { 
    'date' : substring($ts, 9,  2) || '/' || substring($ts, 6,  2) || '/' || substring($ts, 1,  4)
}

let $pages := ('index', 'annuaire', 'evenements', 'videos', 'biblio', 'outils', 'nocomment', 'blog')
return 
  for $i in 1 to 8
  return
    <page name="{$pages[$i]}">{ local:render($pages[$i], $in) }</page>