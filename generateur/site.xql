xquery version "3.1";

declare namespace transform = "http://exist-db.org/xquery/transform";
declare namespace json="http://www.json.org";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
import module namespace markdown = "http://exist-db.org/xquery/markdown";

declare option exist:serialize "method=xml media-type=application/xml indent=yes";

declare variable $base := '/Users/stephane/Comptes/perso/virus/sites/comitesantelibertevendee.fr/www';

declare variable $output := $base || '/pub';

declare variable $local:json-output := <output:serialization-parameters><output:method>json</output:method></output:serialization-parameters>;

declare variable $local:site := util:eval(file:read($base || '/gabarits/' || 'site.xml'));

declare function local:date( $date ) {
    let $year := substring(string(current-dateTime()), 1, 4)
    let $month := substring($date, 6, 2)
    let $sep := if (starts-with($date, $year)) then ' ' else '/'
    return 
        string-join(
            (
            substring($date, 9, 2),
            if (starts-with($date, $year)) then
              switch ($month)
                case '01' return 'Janvier'
                case '02' return 'Février'
                case '03' return 'Mars'
                case '04' return 'Avril'
                case '05' return 'Mai'
                case '06' return 'Juin'
                case '07' return 'Juillet'
                case '08' return 'Août'
                case '09' return 'Septembre'
                case '10' return 'Octobre'
                case '11' return 'Novembre'
                case '12' return 'Décembre'
                default return $month              
            else (
              $month,
              substring($date, 1, 4)
              )
            ), 
            $sep
        )
};

declare function local:image ( $image ) {
  <div class="block border">
      <center>
          <img src="{$image/Source}" width="{$image/Largeur}"/>
      </center>
  </div>  
};

declare function local:tags ( $tags ) {
  if ($tags) then
    <div class="tags">{ for $t in $tags order by $t return <span class="tag">{ $t }</span> }</div>
  else
    ()
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
              then (': ', $f/Commentaire/(*|text()))
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
      for $action at $i in $actions//Action[@Afficher eq 'oui']
      return
        <div class="block border" id="{$action/Ancre}">
          <div class="up"><a href="#top" title="Haut de page">​ᐃ​</a>​</div>        
          <h2>{$i}. {$action/Titre/text()} {
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
 :  Page Outils à partir de bd/outils.xml
 : 
 :)
declare function local:outils ( $file ) {
  let $items := util:eval(file:read($base || '/bd/' || $file))
  return
      for $item in $items//Outil[@Afficher eq 'oui']
      return
        <div class="block border" id="{$item/Numero}">
          <div class="up"><a href="#top" title="Haut de page">​ᐃ​</a>​</div>        
          <h3>Situation n° {$item/Numero/text()}: { $item/Situation/text() }</h3>
          <p><span class="outil">Outil</span> { $item/Moyen/text() }</p>
          {
          for $n in $item/Verbatim/(*|text())
          return
            if (local-name($n) eq 'Eval')
              then util:eval($n/text())
              else $n
          }
        </div>
};

(:~
 : Conversion <Videotheque> vers HTML - DEPRECATED
 : 
 :)
declare function local:videos ( $file ) {
    let $rubriques := $local:site/Contenu/Page[Id eq replace($file, '.xml', '')]/Rubriques
    let $input := util:eval(file:read($base || '/bd/' || $file))
    return
        for $r at $i in $rubriques/Rubrique
        let $inclus := $r/Inclus/Tag
        let $exclus := $r/Exclus/Tag
        return
            <div class="block border" id="{ ($r/Ancre/text(), $r/Tag[1]/text())[1] }">
                <div class="up"><a href="#top" title="Haut de page">​ᐃ​</a>​</div>
                <h2>{$i}. { $r/Titre/text() }</h2>
                {
                if ($r/Presentation) then
                    <blockquote>{ $r/Presentation/(*|text()) }</blockquote>
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
                            { if ($v/Ancre) then attribute { 'id' } { $v/Ancre } else () }
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
                                (
                                if (not($v/Rubrique eq 'Chaîne')) then 
                                  string-join(
                                    (
                                    $v/Duree/text(),
                                    $v/Langue,
                                    if ($v/SousTitre eq 'activer') then 
                                        'sous-titrable'
                                    else if ($v/SousTitre) then 
                                        'sous-titré'
                                    else
                                      (),
                                    'ajouté le ' || $v/Ajout
                                    ),
                                    '| '
                                    )
                                else
                                  'ajouté le ' || $v/Ajout
                                )
                                || ')'
                                }
                            </sup>:
                            { $v/Presentation/(*|text())}
                        </li>
                    }
                </ul>
            </div>
};

declare function local:gen-duree( $duree ) {
  string-join(
    (
    if ($duree/H and $duree/H ne '-')
      then ($duree/H || 'h')
      else (),
    if ($duree/M and $duree/M ne '-')
      then ($duree/M || 'm')
      else (),
    if ($duree/S and $duree/S ne '-')
      then ($duree/S || 's')
      else ()
    ),
    ' '  
    )
};

declare function local:videos-bib ( $file ) {
    let $rubriques := $local:site/Catalogue/Rubrique
    let $input := util:eval(file:read($base || '/bd/' || $file))
    let $list := for $i in distinct-values($input//Rubrique) order by $i return $i    
    return
        for $nom at $i in $list
        let $r := $rubriques[Nom eq $nom]
        return
            <div class="block border" id="{ $nom }">
                <div class="up"><a href="#top" title="Haut de page">​ᐃ​</a>​</div>
                <h2>{$i}. { if ($r) then $r/Titre/text() else $nom }</h2>
                {
                if ($r/Presentation[. ne '']) then
                    <blockquote>{ $r/Presentation/(*|text()) }</blockquote>
                else
                    ()
                }
                <ul>    
                    {
                    for $v in $input//Video[Rubrique eq $nom]
                    let $date := ($v/Ajout, $v/Publication)[1]
                    let $lien := $v/Page/Lien[1] (: seulement le 1er pour le moment :)
                    (: let $fichier :)
                    order by $date descending
                    return
                        <li>
                            { if ($v/Ancre) then attribute { 'id' } { $v/Ancre } else () }
                            <a href="{$lien}">
                                {
                                if ($lien/@Censure eq "oui") then
                                    (<del>{ $v/Titre/text() }</del>, ' (censurée)')
                                else
                                    $v/Titre/text()
                                }
                            </a>
                            <sup>
                                {
                                '(' ||
                                string-join((
                                  if ($v/Rubrique ne 'Chaîne') then 
                                    (
                                    local:gen-duree($v/Duree),
                                    $v/Langue,
                                    if ($v/SousTitre eq 'activer') then 
                                        'sous-titrable'
                                    else if ($v/SousTitre) then 
                                        'sous-titré'
                                    else
                                        ()
                                    )
                                  else
                                    (),
                                  local:datation2($v)
                                  )
                                  , ', ') || ')'
                                }
                            </sup>
                            {
                            local:noms($v/Intervenants, ' avec '),
                            local:source($v/Source),
                            ':',
                            local:tags($v/Tag)                            
                            }                              
                            <div class="presentation">
                              { $v/Presentation/(*|text())[. ne ''] }                              
                            </div>
                        </li>
                    }
                </ul>
            </div>
};


declare function local:sites-bib ( $file ) {
  let $rubriques := $local:site/Catalogue/Rubrique
  let $input := util:eval(file:read($base || '/bd/' || $file))  
  return 
    for $site in $input//Site
    let $rubrique := $site/Rubrique
    let $site-groupe := $site/Groupe
    let $rubrique-config := $rubriques[Nom eq $rubrique]
    let $groupe-config := if ($site-groupe) then $rubrique-config/Groupe[Nom eq $site-groupe] else ()
    let $groupe := if ($groupe-config) then $site-groupe else ()
    let $priority := ($groupe-config/Priorite, $rubrique-config/Priorite, '100')[1]
    group by $rubrique, $groupe
    (:order by $rubrique, $groupe:)
    order by number(head($priority))
    return 
      let $titre := ($groupe-config/Titre, $rubrique-config/Titre, string-join(($rubrique, $groupe), ' '))[1]
      return    
        <div class="block border" id="{string-join(($rubrique, $groupe), '-')}">
          <div class="up"><a href="#top" title="Haut de page">​ᐃ​</a>​</div>
          <h2>{ $titre }</h2>
          {
          if ($rubrique/Presentation) then
              <blockquote>{ $rubrique/Presentation/(*|text()) }</blockquote>
          else
              ()
          }
          <table class="victimes">
            {   
            let $contact := exists($site/Contact) or exists($site/Telegram)          
            let $departement := exists($site/Localisation/Departement[. ne '85'])
            return (
              <tr>
                {
                if ($departement)
                  then <th>Département</th>
                  else ()
                }
                <th>Tags</th>
                <th>Site</th>
                <th>Description</th>
                {
                if ($contact)
                  then <th>Contact</th>
                  else ()
                }
              </tr>,
              for $s in $site
              return
                <tr>
                  {
                  if ($departement)
                    then <td>{ string-join($s/Localisation/Departement, ', ')  }</td>
                    else ()
                  }
                  <td>{ string-join($s/Tag, ', ')  }</td>
                  <td>
                    <a href="{$s/Lien}">{ $s/Titre/text() }</a>
                  </td>
                  <td>
                  {
                  (: should be a <p> or simple text() :)
                  if ($s/Presentation)
                    then $s/Presentation/(*|text())
                    else ()
                  } 
                  </td>
                  {
                  if ($contact) then
                    <td>
                      {
                      if ($s/Contact)
                        then <p><a href="mailto:{$s/Contact}">{$s/Contact/text()}</a></p>
                        else (),
                      if ($s/Telegram/Contact)
                        then <p>accès telegram sur <a href="mailto:{$s/Telegram/Contact}">demande</a></p>
                        else (),
                      if ($s/Telegram/Lien)
                        then <p><a href="{$s/Telegram/Lien}">telegram</a></p>
                        else ()
                      }
                    </td>
                  else
                    ()
                  }
                </tr>
              )
            }
          </table>                
        </div>  
  };

(:~
 : Table annuaire collectifs locaux
 : 
 :)

(:<blockquote>Les groupes présentés dans cette table sont des collectifs vendéens qui ont tissé des liens avec le comité santé liberté vendée 85 ou qui en sont issus. Les groupes de type <i>territoire</i> sont des groupes locaux liés à une communauté de communes et d'agglomération. Tous les groupes à ce jour n'ont pas encore de référent. Pour devenir référent ou pour participer à une action décentralisée écrivez à l'adresse du groupe correspondant à votre <a href="https://www.maisondescommunes85.fr/annuaire/com-com">communauté de commune</a>.</blockquote>
<p style="margin-left:20px">Pour connaître votre communauté de commune vous pouvez consulter une carte <a href="https://france.comersis.com/map/epci/intercommunalites-de-la-Vendee.png">en ligne</a> (sur le site des <a href="https://france.comersis.com/carte-epci-communes.php?dpt=85">éditions Comersis</a>).
</p>:)
declare function local:annuaire-departement ( $database ) {
  <div class="block border" id="cslv85">
    <div class="up"><a href="#top" title="Haut de page">​ᐃ​</a>​</div>
    <h2>Collectifs Vendéens liés au CSLV 85</h2>        
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
              <div class="block border" id="{$r/Ancre/text()}">
                <div class="up"><a href="#top" title="Haut de page">​ᐃ​</a>​</div>
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
                    return local:rows($r/Tag, $sub/Inclus/Tag, $sub/Exclus/Tag, $sub, $input)
                  else
                    local:rows((), (), (), $r, $input) (: a flat Rubrique :)
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

declare function local:rows ( $root-tag as element()*, $inclus, $exclus, $r, $database ) {
  let $entries := 
    for $entry in $database//Groupe[empty($root-tag) or Tag = $root-tag][empty(@Afficher) or @Afficher eq 'oui'][empty(Partenaire)]
    where (empty($r/Tag) or $entry/Tag = $r/Tag)
          and
          (
          empty($r/Departement)
          or (exists($r/Departement/Inclus) and $entry/Departement = $r/Departement/Inclus)
          or (exists($r/Departement/Exclu) and not($entry/Departement = $r/Departement/Exclu))
          )
          and          
          (
          empty($inclus) or $entry/Tag = $inclus
          )
          and 
          (
          empty($exclus) or not($entry/Tag = $exclus)
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
              if ($root-tag = 'regional' and $e/Tag = 'regional') then
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
            if ($root-tag = 'regional' or $e/Contact or $e/Telegram) then
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

declare function local:gen-tags ( $item ) {
  <span class="vtoptag" style="float:right;">
    {
    $item/Tag ! <span class="tag">{ ./text() }</span>
    }    
  </span>  
};

(:~
 : DEPRECATED
 :)
declare function local:biblio ( $file ) {
    let $rubriques := util:eval(file:read($base || '/gabarits/' || 'site.xml'))/Contenu/Page[Id eq replace($file, '.xml', '')]/Rubriques
    let $input := util:eval(file:read($base || '/bd/' || $file))
    return
        for $r at $i in $rubriques/Rubrique
        let $inclus := $r/Inclus/Tag
        let $exclus := $r/Exclus/Tag
        return
            <div class="block border">
                { if ($r/@Ancre) then attribute { 'id' } { string($r/@Ancre) } else () }
                <div class="up"><a href="#top" title="Haut de page">​ᐃ​</a>​</div>                
                <h2>{$i}. { $r/Titre/text() }</h2>
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
                    where     (empty($inclus) or $i/Tag = $inclus)
                          and (empty($exclus) or not($i/Tag = $exclus))                    
                    return
                        <li>
                            {
                            if ($i/Ancre) then attribute { 'id' } { $i/Ancre } else (),
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
                                  if (matches(string($i/Presentation), '\.\s*$') or matches(string($i/Presentation), '\?\s*$'))
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

declare function local:noms ( $auteurs, $liaison ) {
  if ($auteurs/Nom) then
    <span>{ $liaison }{
      if (count($auteurs/Nom) eq 1)
        then $auteurs/Nom/text()
        else if (count($auteurs/Nom) eq 2)
          then string-join($auteurs/Nom, ' et ')
          else 
            concat(
              string-join($auteurs/Nom[position() < count($auteurs/Nom)], ', '),
              ' et ',
              $auteurs/Nom[last()]
              )
      }
    </span>
  else
    ()
};

declare function local:source ( $source as xs:string? ) {
  if ($source)
    then <span> pour {$source} </span>
    else ()
};

declare function local:datation1( $i ) {  
  if ($i/Publication and $i/Ajout and $i/Publication ne $i/Ajout) then
    <sup>({
      if ($i/Publication)
        then ("publié le " || local:date($i/Publication) || ", ") 
        else () 
      }ajouté le { local:date($i/Ajout)})
    </sup>
  else if ($i/Publication) then
    <sup>(publié le { local:date($i/Publication)})</sup>
  else if ($i/Ajout) then
    <sup>(ajouté le { local:date($i/Ajout)})</sup>
  else
    ()    
};

declare function local:datation2( $i ) {  
  if ($i/Publication and $i/Ajout and $i/Publication ne $i/Ajout) then
    concat(
      if ($i/Publication)
        then ("publié le " || local:date($i/Publication) || ", ") 
        else (),
      'ajouté le ',
      local:date($i/Ajout)
      )
  else if ($i/Publication) then
    concat('publié le ', local:date($i/Ajout))
  else if ($i/Ajout) then
    concat('ajouté le ', local:date($i/Ajout))
  else
    ()    
};

declare function local:biblio-bib ( $file ) {
    let $rubriques := $local:site/Catalogue/Rubrique
    let $input := util:eval(file:read($base || '/bd/' || $file))
    let $list := for $i in distinct-values($input//Rubrique) order by $i return $i
    return
        for $nom at $i in $list
        let $r := $rubriques[Nom eq $nom]
        return
            <div class="block border" id="{ $nom }">
                <div class="up"><a href="#top" title="Haut de page">​ᐃ​</a>​</div>                
                <h2>{$i}. { if ($r) then $r/Titre/text() else $nom }</h2>
                {
                if ($r/Presentation[. ne '']) then
                    <blockquote>{ $r/Presentation/(*|text()) }</blockquote>
                else
                    ()
                }
                <ul>    
                    {
                    for $i in $input//Article[Rubrique eq $nom]
                    let $date := ($i/Publication, $i/Ajout)[1]
                    let $lien := $i/Page/Lien[1] (: seulement le 1er pour le moment :)
                    let $pdf := $i/PDF/Lien[1] (: seulement le 1er pour le moment :)
                    order by $date descending
                    return
                        <li>
                            {
                            if ($i/Ancre) then attribute { 'id' } { $i/Ancre } else (),
                            if ($lien) then
                              <a href="{$lien}">{ $i/Titre/text() }</a>
                            else if ($pdf) then
                              <a href="{$pdf}">{ $i/Titre/text() }</a>
                            else
                              <b>{ $i/Titre/text() }</b>,
                            if ($pdf) then
                              <a href="{$pdf}"><img src="img/pdf.png" width="32px" alt="PDF" style="vertical-align:text-bottom"/></a>
                            else
                              (),
                            local:noms($i/Auteurs, ' par '),
                            local:source($i/Source),
                            local:datation1($i),
                            local:tags($i/Tag)                            
                            }
                            <div class="presentation">
                              {
                              if ($i/Presentation) then
                                let $comment := $i/Presentation/(*|text())[. ne '']
                                return (
                                  $comment
                                  )
                              else
                                ()
                              }                              
                            </div>
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
      <page name="{$file}">{ file:serialize(util:eval($page), $output || '/' || replace($file, '.xml', '.html'), ()) }</page>
};

declare function local:render( $gabarit, $in ) {
    if ($gabarit eq 'blog') then
      local:blog ($gabarit)
    else      
      let $page := file:read($base || '/gabarits/' || $gabarit || '.xml')
      return
          file:serialize(util:eval($page), $output || '/' || $gabarit || '.html', ())
};

declare function local:victimes( ) {
  let $victimes := concat('file://', $base, '/bd/', 'victimes-bib.xml') 
  let $stylesheet := concat('file://', $base, '/transfos/', 'victimes.xsl')
  let $FSPath := concat('file://', $output, '/victimes.html')
  let $params := <parameters>
                   <param name="exist:stop-on-warn" value="yes"/>
                   <param name="exist:stop-on-error" value="yes"/>
                 </parameters>  
  let $victimes := transform:transform(fn:doc($victimes), $stylesheet, $params)
  return (
    file:serialize($victimes, $FSPath, ()),
    $victimes
    )[last()]  
};



declare function local:lister-rubriques ( $name ) {
  let $rubriques := $local:site/Contenu/Page[Id eq $name]/Rubriques
  return (
    <p class="rubriques" style="text-align:center">Sommaire</p>,
    <p style="text-align:center">
    {
    for $t at $i in $rubriques/Rubrique
    let $ancre := $t/(@Ancre | Ancre)
    where not($t/@Menu eq 'off')
    return (
      if ($ancre)
        then <a href="#{string($ancre)}">{$i}. {$t/Titre/text()}</a>
        else <span>{ $t/Titre/text() }</span>,
      if ($i < count($rubriques/Rubrique))
        then <br/>
        else ()
      )
    }
    </p>      
    )
};

declare function local:lister-rubriques-bib ( $name, $file ) {
  let $rubriques := $local:site/Catalogue/Rubrique
  let $input := util:eval(file:read($base || '/bd/' || $file))  
  let $list := for $i in distinct-values($input//Rubrique) order by $i return $i
  let $total := count($list)
  return (
    <p class="rubriques" style="text-align:center">Rubriques</p>,
    <p style="text-align:center">
    {
    for $name at $i in $list
    let $t := $rubriques[Nom eq $name]
    return (
      <a href="#{$name}">{$i}. { if ($t) then $t/Titre/text() else $name }</a>,
      if ($i < $total)
        then <br/>
        else ()
      )
    }
    </p>      
    )
};


declare function local:lister-sites-bib ( $name, $file ) {
  let $rubriques := $local:site/Catalogue/Rubrique
  let $input := util:eval(file:read($base || '/bd/' || $file))  
  let $list := for $i in distinct-values($input//Rubrique) order by $i return $i
  let $total := count($list)
  return (
    <p class="rubriques" style="text-align:center">Rubriques</p>,
    <p style="text-align:center">
    {
    for $site in $input//Site
    let $rubrique := $site/Rubrique
    let $site-groupe := $site/Groupe
    let $rubrique-config := $rubriques[Nom eq $rubrique]
    let $groupe-config := if ($site-groupe) then $rubrique-config/Groupe[Nom eq $site-groupe] else ()
    let $groupe := if ($groupe-config) then $site-groupe else ()
    let $priority := ($groupe-config/Priorite, $rubrique-config/Priorite, '100')[1]
    group by $rubrique, $groupe
    (:order by $rubrique, $groupe:)
    order by number(head($priority))
    return
        let $titre := ($groupe-config/Titre, $rubrique-config/Titre, string-join(($rubrique, $groupe), ' '))[1]
        return
        (
        <a href="#{string-join(($rubrique, $groupe), '-')}">{ $titre }</a>,
        <span>({count($site)})</span>,
        <br/>
        )
    }
    </p>      
    )
};

declare function local:lister-outils ( $filename ) {
  let $outils := util:eval(file:read($base || '/bd/' || $filename))
  return (
    <p class="rubriques" style="text-align:center">Sommaire</p>,
    <p style="text-align:center">
    {
    for $t at $i in $outils/Outil
    let $ancre := $t/Numero
    return (
      <a href="#{string($ancre)}">#{string($ancre) || ' '} { upper-case(substring($t/Situation, 1, 1)) || substring($t/Situation, 2) }</a>,
      if ($i < count($outils/Outil))
        then <br/>
        else ()
      )
    }
    </p>
    )
};

declare function local:lister-actions ( $filename ) {
  let $items := util:eval(file:read($base || '/bd/' || $filename))
  return (
    <p class="rubriques" style="text-align:center">Sommaire</p>,
    <p style="text-align:center">
    {
    for $t at $i in $items/Action[@Afficher eq 'oui']
    let $ancre := $t/Ancre
    return (
      <a href="#{string($ancre)}">{$i}. { ($t/TitreCourt/text(), $t/Titre/text())[1] }</a>,
      if ($i < count($items/Action))
        then <br/>
        else ()
      )
    }
    </p>
    )
};

(:
Convertir au format JSON les Auteurs, etc. pour le widget actuel 
:)
declare function local:export-bib-to-json ( $nodes as item()* ) {
  for $node in $nodes
  return
    if ($node/@Afficher eq 'non') then
      ()
    else
      typeswitch($node)
        case text()
          return $node
        case attribute()
          return $node
        case element()
          return
            let $tag := local-name($node)
            return
              if ($tag eq 'Page') then
                (: simplification : always singleton :)
                <Page>{ local:export-bib-to-json($node/Lien[1]) }</Page>
              else if ($tag eq 'PDF') then
                (: simplification : always singleton :)
                <PDF>{ local:export-bib-to-json($node/Lien[1]) }</PDF>
              else if ($tag eq 'Presentation') then
                element { $tag }
                  {
                  util:serialize($node/(text()|*),  "method=xml media-type=application/xml indent=yes")
                  }
              else if ($tag eq 'Serie') then
                ()
                (: 
                BUG in JSON serialization that adds an extra {
                NOT needed for this widget
                <Serie>
                  {
                  for $article in $node/Article
                  return
                    <Article json:array="true">{ local:export-bib-to-json($node/*) }</Article>
                  }
                </Serie>:)
              else if ($tag eq 'Tag') then
                <Tag json:array="true">{ $node/text() }</Tag>
              else
                element { $tag }
                  { local:export-bib-to-json($node/(attribute()|node())) }
        default
          return $node
};
  
declare function local:export-bd-to-json ( $nodes as item()* ) {
  for $node in $nodes
  return
    if ($node/@Afficher eq 'non') then
      ()
    else
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
  let $source := element { $tag || 's' } 
                   {
                   local:export-bib-to-json(util:eval(file:read($base || '/bd/' || $filename || '.xml'))//Ressources/*[local-name() eq $tag])
                   }
  let $data := <data>{'var ' || $tag || 's' || ' = ' || replace(replace(serialize($source, $local:json-output), '\{"' || $tag || '":', ''), '\}$', '') || ';'}</data>
  return 
    file:serialize($data/text(), $output || '/json/' || $filename || '.js', ())
};

let $ts := current-dateTime()
let $in := map { 
    'date' : substring($ts, 9,  2) || '/' || substring($ts, 6,  2) || '/' || substring($ts, 1,  4)
}

let $pages := ('index', 'manifeste', 'annuaire', 'evenements', 'videos', 'biblio', 'outils', 'nocomment', 'blog', 'json', 'actions')
(:                1          2           3            4           5         6         7           8          9      10        11 :)
return 
  for $i in (1, 6)
  return 
    (
    if ($i = (5, 10))
      then local:json('videos-bib', 'Video')
      else (),
    if ($i = (6, 10))
      then local:json('articles-bib', 'Article')
      else (),
    if (not($pages[$i] eq 'json'))
      then <page name="{$pages[$i]}">{ local:render($pages[$i], $in) }</page>
      else ()
    )