xquery version "3.1";

declare namespace transform = "http://exist-db.org/xquery/transform";
declare namespace json="http://www.json.org";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
import module namespace markdown = "http://exist-db.org/xquery/markdown";

declare option exist:serialize "method=xml media-type=application/xml indent=yes";

declare variable $base := '/Users/stephane/Comptes/perso/virus/sites/comitesantelibertevendee.fr/www';

declare variable $local:json-output := <output:serialization-parameters><output:method>json</output:method></output:serialization-parameters>;

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
              then ': ' ||  $f/Commentaire/(*|text())
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
 :  Page Actions à partir de bd/actions.xml
 : 
 :)
declare function local:actions ( $file ) {
  let $actions := util:eval(file:read($base || '/bd/' || $file))
  return
      for $action in $actions//Action[@Afficher eq 'oui']
      return
        <div class="block border" id="{$action/Ancre}">
          <h2>{$action/Titre/text()} {
            if ($action/Limite) then <span class="outil" style="float:right">Avant le {$action/Limite/text()}</span> else (),
            if ($action/Drapeau) then <span class="outil" style="float:right">{$action/Drapeau/text()}</span> else ()
            }
          </h2>
          <blockquote>
            {$action/Presentation/(*|text())}              
          </blockquote>        
          {$action/Verbatim/(*|text())}
        </div>            
};

(:~
 :  Page Agenda à partir de bd/actions.xml
 : 
 :)
declare function local:agenda ( $file ) {
  let $evenements := util:eval(file:read($base || '/bd/' || $file))
  return
      for $evenement in $evenements//Evenement[@Afficher eq 'oui']
      return
        <div class="block border" id="{$evenement/Ancre}">
          <h2>{$evenement/Titre/(*|text())}</h2>
          <blockquote>
            {$evenement/Presentation/(*|text())}              
          </blockquote>        
          {$evenement/Verbatim/(*|text())}
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
        let $inclus := $r/Tag/Inclus
        let $exclus := $r/Tag/Exclus
        return
            <div class="block border" id="{ ($r/Ancre/text(), $r/Tag[1]/text())[1] }">
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
                    let $ajout := $v/Ajout
                    order by $ajout descending
                    where     (empty($inclus) or $v/Tag = $inclus)
                          and (empty($exclus) or not($v/Tag = $exclus))
                    return
                        <li>
                            <a href="{$v/Lien/Base}{$v/Lien/Chemin}">
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
                            { $v/Presentation/(*|text())}
                        </li>
                    }
                </ul>
            </div>
};

(:~
 : Table annuaire collectifs locaux
 : 
 :)
declare function local:annuaire-departement ( $database ) {
  <div class="block border">
    <h2>Collectifs locaux Vendéens liés au CSLV 85</h2>
    <blockquote>Les groupes présentés dans cette table sont des collectifs vendéens qui ont tissé des liens avec le comité santé liberté vendée 85 ou qui en sont issus. Les groupes de type <i>territoire</i> sont des groupes locaux liés à une communauté de communes et d'agglomération. Tous les groupes à ce jour n'ont pas encore de référent. Pour devenir référent ou pour participer à une action décentralisée écrivez à l'adresse du groupe correspondant à votre <a href="https://www.maisondescommunes85.fr/annuaire/com-com">communauté de commune</a>.</blockquote>
    <p style="margin-left:20px">Pour connaître votre communauté de commune vous pouvez consulter une carte <a href="https://france.comersis.com/map/epci/intercommunalites-de-la-Vendee.png">en ligne</a> (sur le site des <a href="https://france.comersis.com/carte-epci-communes.php?dpt=85">éditions Comersis</a>).
    </p>
        
    <table class="victimes">
      <tr>
        <th>Genre</th>
        <th>Nom</th>
        <th>Description</th>
        <th>Contact (cliquez pour écrire)</th>
      </tr>
      {
      for $groupe in $database//Groupe[Departement = '85'][Partenaire eq 'cslv-85'][empty(@Afficher) or @Afficher eq 'oui']
      return
        <tr>
          <td>
            { $groupe/Genre/text() }
          </td>
          <td>
            {
            if ($groupe/Lien) then
              <a href="{$groupe/Lien}">{ $groupe/Nom/text() }</a>
            else if (starts-with($groupe/Nom, 'CSLV 85')) then
              'CSLV 85'
            else
              $groupe/Nom/text()
            }
          </td>
          <td>
          {
          (: should be a <p> or simple text() :)
          if ($groupe/Presentation)
            then $groupe/Presentation/(*|text())
            else ()
          } 
          </td>
          <td>
            {
            if ($groupe/Contact) then 
              <p>
                <a data-mail1="{substring-before($groupe/Contact, '@')}" data-mail2="{substring-after($groupe/Contact, '@')}">
                { 
                if ($groupe/ContactSubject)
                  then attribute { 'data-contact' } { $groupe/ContactSubject/text() }
                  else ()
                 }contact</a>
              </p>
            else
              (),
            if ($groupe/Telegram/Lien) then
              <p><a href="{$groupe/Telegram/Lien}">telegram</a></p>
            else if ($groupe/Telegram/Contact) then
              <p>
                <a data-mail1="{substring-before($groupe/Telegram/Contact, '@')}" data-mail2="{substring-after($groupe/Telegram/Contact, '@')}" data-subject="Demande%20accès%20telegram">accès telegram</a>
                {
                if ($groupe/Telegram/Commentaire) 
                  then <span style="font-size:90%">{ $groupe/Telegram/Commentaire }</span>
                  else ()
                }
              </p>
            else
              ()              
            }
          </td>
        </tr>
      }
    </table>
  </div>  
};
  
(:~
 : Conversion <Annuaire> vers HTML
 : 
 :)
declare function local:annuaire ( $file ) {
    let $rubriques := util:eval(file:read($base || '/gabarits/' || 'site.xml'))/Contenu/Page[Id eq replace($file, '.xml', '')]/Rubriques
    let $input := util:eval(file:read($base || '/bd/' || $file))
    return (
        local:annuaire-departement($input),
        for $r in $rubriques/Rubrique[empty(@Afficher) or @Afficher = 'oui']
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
                    ()
                }
                <table class="victimes">
                  {      
                  if ($r/Tag = 'regional') then
                    <tr>
                      <th>Département</th>
                      <th>Site</th>
                      <th>Description</th>
                      <th>Contact</th>
                    </tr>
                  else
                    (),
                  if ($r/Rubrique) then (: nested Rubrique :)
                    for $sub in $r/Rubrique
                    return local:rows($r/Tag, $sub, $input)
                  else
                    local:rows((), $r, $input) (: a flat Rubrique :)
                  }
                </table>                
              </div>
        )
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

declare function local:rows ( $root-tag as element()*, $r, $database ) {
  let $entries := 
    for $entry in $database//Groupe[empty($root-tag) or Tag = $root-tag][empty(@Afficher) or @Afficher eq 'oui'][empty(Partenaire)]
    where (empty($r/Tag) or $entry/Tag = $r/Tag)
          and
          (
          empty($r/Departement)
          or (exists($r/Departement/Inclus) and $entry/Departement = $r/Departement/Inclus)
          or (exists($r/Departement/Exclu) and not($entry/Departement = $r/Departement/Exclu))
          )
    return
      $entry
  return
   (
    (:if ($root-tag)
      then <h3>{$r/Titre/text()}</h3>
      else (),:)
    if ($entries) then
        for $e in $entries
        return
          <tr>
            <td>
              {
              if ($e/Tag = 'regional') then
                string-join($e/Departement, ', ')
              else  
                string-join($e/Tag[not(. = $root-tag)], ', ') 
              }
            </td>
            <td>
              <a href="{$e/Lien}">{ $e/Nom/text() }</a>
            </td>
            <td>
            {
            (: should be a <p> or simple text() :)
            if ($e/Presentation)
              then $e/Presentation/(*|text())
              else ()
            } 
            </td>
            {
            if ($e/Contact or $e/Telegram) then
              <td>
                {
                if ($e/Telegram/Lien)
                  then <span> Lien <a href="{$e/Telegram/Lien}">telegram</a>.</span>
                  else (),
                if ($e/Contact)
                  then <a data-mail1="{substring-before($e/Contact, '@')}" data-mail2="{substring-after($e/Contact, '@')}">contact</a>
                  else ()
                }
              </td>
            else
              ()
            }
          </tr>
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
                { if ($r/@Ancre) then attribute { 'id' } { string($r/@Ancre) } else () }
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
                    let $date := ($i/Publication, $i/Ajout)[1]
                    order by $date descending
                    return
                        <li>
                            {
                            if ($i/Lien) then
                              <a href="{$i/Lien[1]/Base}{$i/Lien[1]/Chemin}">{ $i/Titre/text() }</a>
                            else if ($i/LienPDF) then
                              <a href="{$i/LienPDF}">{ $i/Titre/text() }</a>
                            else
                              <b>{ $i/Titre/text() }</b>,
                            if ($i/LienPDF) then
                              <a href="{$i/LienPDF}"><img src="img/pdf.png" width="32px" alt="PDF" style="vertical-align:text-bottom"/></a>
                            else
                              ()
                            }
                            <span> par { $i/Auteur/text() }</span>                            
                            <sup>({if ($i/Publication) then ("publié le " || local:date($i/Publication) || ", ") else () }ajouté le { local:date($i/Ajout) })</sup>
                            <p>
                              {
                              if ($i/Presentation) then
                                let $comment := $i/Presentation/(*|text())
                                return (
                                  $comment,
                                  if (ends-with(string($i/Presentation), '.') or ends-with(string($i/Presentation), '?'))
                                    then ' '
                                    else '. '
                                  )
                              else
                                ()
                              }                              
                            </p>
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

declare function local:verbatim( $verbatim ) {
  if ($verbatim/@Format eq 'markdown') then
    markdown:parse($verbatim)
  else
    $verbatim/*  
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

declare function local:victimes( ) {
  let $victimes := concat('file://', $base, '/bd/', 'victimes.xml') 
  let $stylesheet := concat('file://', $base, '/transform/', 'victimes.xsl')
  let $params := <parameters>
                   <param name="exist:stop-on-warn" value="yes"/>
                   <param name="exist:stop-on-error" value="yes"/>
                 </parameters>  
  return    
    transform:transform(fn:doc($victimes), $stylesheet, $params)
};

declare function local:export-bd-to-json ( $nodes as item()* ) {
  for $node in $nodes
  return
    typeswitch($node)
      case text()
        return $node
      case attribute()
        return $node
      case element()
        return
          let $tag := local-name($node)
          return
            if ($tag eq 'Presentation') then
              element { $tag }
                {
                util:serialize($node/(text()|*),  "method=xml media-type=application/xml indent=yes")
                }
            else if ($tag eq 'Tag') then
              <Tag json:array="true">{ $node/text() }</Tag>
            else
              element { $tag }
                { local:export-bd-to-json($node/(attribute()|node())) }
      default
        return $node
};

declare function local:json ( $filename, $tag ) {
  let $source := local:export-bd-to-json(util:eval(file:read($base || '/bd/' || $filename || '.xml'))//*[local-name() eq $tag])
  let $data := <data>{'var ' || $tag || ' = ' || serialize($source, $local:json-output) || ';'}</data>
  return 
    file:serialize($data/text(), $base || '/json/' || $filename || '.js', ())
};

let $ts := current-dateTime()
let $in := map { 
    'date' : substring($ts, 9,  2) || '/' || substring($ts, 6,  2) || '/' || substring($ts, 1,  4)
}

let $pages := ('index', 'manifeste', 'annuaire', 'evenements', 'videos', 'biblio', 'outils', 'nocomment', 'blog', 'json', 'actions')
(:                1          2           3            4           5         6         7           8          9      10        11 :)
return 
  for $i in (6)
  return 
    (
    if ($i = (5, 10))
      then local:json('videos', 'Videos')
      else (),
    if ($i = (6, 10))
      then local:json('biblio', 'Articles')
      else (),    
    if (not($pages[$i] eq 'json'))
      then <page name="{$pages[$i]}">{ local:render($pages[$i], $in) }</page>
      else ()
    )