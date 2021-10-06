(: Apple e-Pub to XML :)

let $article := <XXX/>
return <Verbatim>
    {    
         for $p in $article/(p|h4)
          return
             if (local-name($p) eq 'h4') then
                 <h3>{string($p)}</h3>
            else
              <p>
                  {
            for $s in $p/(a | span)
            return 
                if (local-name($s) eq 'a') then
                    <a href="{$s/@href}">{string($s)}</a>
                else if ($s[not($s/preceding-sibling::span[@class = ('c1 c3', 'c1 c4')])]/@class = ('c1 c4')) then 
                    <b>{$s/text() }</b>
                else if ($s/@class = ('c1 c6')) then 
                    <b>{$s/text() }</b>
                else if ($s/@class eq 'c1 c7') then
                    <i>{ $s/text() }</i>
                else if ($s/@class eq 'c1 c8') then
                    <i><b>{ $s/text() }</b></i>
                else
                    $s/text()
                  }
                  </p>
    }</Verbatim> 
    