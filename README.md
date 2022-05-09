Site CSLV 85
============

Générateur et contenu 

1. du site [www.comitesantelibertevendee.fr](http://www.comitesantelibertevendee.fr) du Comité Santé Liberté Vendée 85 (CSLV 85)

1. de la [bibliothèque ouverte du CSLV 85](https://sceptimus.github.io/cslv/) 

Pages statiques générées à partir de fichiers XML.

## Organisation

### Contenu

* `bd/annuaire.xml` : flux XML des entrées de la page Annuaire
* `bd/biblio.xml` : flux XML des entrées de la page Lecture
* `bd/videos.xml` : flux XML des entrées de la page Videos
* `bd/films.xml` : flux XML de films, utilisé pour insérer des liens vers des listes de film (Boite à outils)
* `blog/*.xml`: billets de blog, 1 fichier XML par billet
* `nocomment/*` : images intégrées dans la page nocomment du site
* `img/*` : images intégrées dans les pages du site

### Présentation

* `gabarits/site.xml`: configuration du site, liste des pages et des rubriques à inclure dans chaque page
* `gabarits/*.xml`: gabarits des pages à inclure dans le site, 1 fichier par page
* `site.js` : fichier javascript global du site
* `index.css` : fichier de style de la page Manifeste
* `page.css` : fichier de style des autres pages du site

### Générateur

* `generateur/site.xql` : script XQuery pour générer l'ensemble du site à partir des flux XML et des gabarits

Note: le générateur contient aussi les templates HTML qui représentent les blocs internes aux pages

## Récupération du dépôt

Si vous souhaiez cloner le dépot git dans votre répertoire `ICI` en le nommant `www` exécutez dans un terminal les commandes :

    cd {chemin vers}/ICI
    git clone https://github.com/{your git identifier}/cslv.git www

## Génération du site

Vous devez installer l'application [eXist-DB](http://exist-db.org/exist/apps/homepage/index.html) (base de données XML).

Editez le script `generateur/site.xql` dans la variable `$base` indiquez le chemin jusqu'à la racine de la copie locale du dépot git cslv:

    declare variable $base := '.../ICI/www';

Puis placez-vous dans le répertoire d'installation de eXist-DB et exécutez (*) : 

    % ./bin/client.sh -u admin -P MOT-DE-PASSE-BD -F .../ICI/www/generateur/site.xql 
    -u admin -P foo -F .../ICI/www/generateur/site.xql
    Using locale: fr_FR.UTF-8
    eXist version 4.7.0 (64ba51345), Copyright (C) 2001-2021 The eXist-db Project
    eXist-db comes with ABSOLUTELY NO WARRANTY.
    This is free software, and you are welcome to redistribute it
    under certain conditions; for details read the license file.

    Connecting to database...
    Connected :-)
    <page name="index">true</page><page name="annuaire">true</page><page name="evenements">true</page><page name="videos">true</page><page name="biblio">true</page><page name="outils">true</page><page name="nocomment">true</page><page name="blog">
        <page name="cri-du-coeur.xml">true</page>
        ...
    </page>%                            

Le fichiers HTML générés remplacent les fichiers de même nom dans le répertoire `ICI/www` avec les données à jour.

(*) vous pouvez également copier/coller le script `site.xql` dans l'éditeur web eXide de eXist-DB pour l'exécuter avec le bouton _Eval_

## Contribution au contenu du site

Vous pouvez directement ajouter du contenu au site en ajoutant les entrées correspondantes dans les fichiers de flux XML, ou en ajoutant un fichier dans le répertoire de billets de blog. Demandez ensuite à un développeur d'intégrer vos modifications dans le fichier `gabarits/site.xml`si besoin et de régénérer le site (cf instructions ci-dessus).
