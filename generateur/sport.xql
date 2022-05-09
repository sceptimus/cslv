xquery version "3.1";

declare variable $base := '/Users/stephane/Comptes/perso/virus/sites/comitesantelibertevendee.fr/www';


declare function local:sport( ) {
  let $sport := concat('file://', $base, '/bd/', 'sport.xml') 
  let $stylesheet := concat('file://', $base, '/transfos/', 'annuaire.xsl')
  let $FSPath := concat('file://', $base, '/sport.html')
  let $params := <parameters>
                   <param name="exist:stop-on-warn" value="yes"/>
                   <param name="exist:stop-on-error" value="yes"/>
                 </parameters>  
  let $res := transform:transform(fn:doc($sport), $stylesheet, $params)
  return (
    file:serialize($res, $FSPath, ()),
    $res
    )[last()]  
};

local:sport()


(:return
  <html>
      <body>
          {
          let $sport := fn:doc($file)
          return
              for $feder in $sport//federation
              return
                  <div>
                      <p>
                          { $feder/acronyme/text() }<br/>
                          { $feder/addresse/rue/text() }<br/>
                          { $feder/addresse/code/text() } { $feder/addresse/ville/text() }
                      </p>
                      <p>
                          <a href="mailto:{$feder/email}">écrire</a>, visiter : <a href="{$feder/siteweb}">site web</a>
                      </p>
                  </div>
          }
      </body>
  </html>:)