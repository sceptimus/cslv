xquery version "3.1";

declare variable $base := '.../comitesantelibertevendee.fr/www';

declare function local:videos ( $file ) {
    let $input := util:eval(file:read($base || '/bd/' || $file))
    return
        for $r in $input//Rubrique
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

declare function local:render( $gabarit, $in ) {
    let $page := file:read($base || '/gabarits/' || $gabarit || '.xml')
    return
        file:serialize(util:eval($page), $base || '/' || $gabarit || '.html', ())
};

let $ts := current-dateTime()
let $in := map { 
    'date' : substring($ts, 9,  2) || '/' || substring($ts, 6,  2) || '/' || substring($ts, 1,  4)
}

return
    local:render('videos', $in)