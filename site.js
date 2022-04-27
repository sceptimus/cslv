function ouvrir( tag ) {
  var n = document.getElementsByClassName(tag + ' sub');
  var i, k;
  for (i = 0; i < n.length; i++) {
    k = n[i].className;
    n[i].className = k.replace('off ', '');
    }
  n = document.getElementsByClassName('rubrique top');
  for (i = 0; i < n.length; i++) {
    k = n[i].className;
    if (k.indexOf('on') === -1) {
      n[i].className = 'off ' + k;
    }
  }
};

function fermer( tag ) {
  var s = document.getElementsByClassName('off rubrique');
  var n = new Array(s.length);
  var i, k;
  for (i = 0; i < s.length; i++) { n[i] = s[i]; }; // clone because s live array
  for (i = 0; i < n.length; i++) {
    k = n[i].className;
    n[i].className = k.replace('off ', '');
  }
  n = document.getElementsByClassName(tag + ' sub');
  for (i = 0; i < n.length; i++) {
    k = n[i].className;
    if (k.indexOf('on') === -1) {
      n[i].className = 'off ' + k;
    }
  }  
};

function basculerPresse( ) {
  var n = document.getElementById('contenuPresse');
  if (n.className === 'cache') {
    n.className = '';
    n = document.getElementById('activerPresse');
    n.textContent = 'Cacher';    
  } else {
    n.className = 'cache';
    n = document.getElementById('activerPresse');
    n.textContent = 'Montrer';    
  }
};

// JukeBox Wigdet

class JukeBox {
  
  constructor(host, database) {
    this.root = host;
    this.BD = database;
    this.CUR = 0;
    $('.vtopmax', this.root).text(this.BD.length);
    $('.vtopaction', this.root).on('click', this.changerVideo.bind(this));     
    $('.vtopavant', this.root).on('click', this.videoPrecedente.bind(this));     
    $('.vtopapres', this.root).on('click', this.videoSuivante.bind(this));     
    this.installerVideo(this.BD.length - 1);
  }

  formatDate (s) {
    if (s) {
      var c = s.split('-');
      return c[2] + '/' + c[1] + '/' + c[0];
    } else {
      return '-';
    }
  }

  formatDuree (d) {
    var d = 
      (d.hasOwnProperty('H') ? d.H : '--') 
        + ':' +
      (d.hasOwnProperty('M') ? d.M : '--') 
        + ':' +
      (d.hasOwnProperty('S') ? d.S : '00');
    return d
  }
  
  installerVideo(i) {
    var v = this.BD[i];
    $('.vtopurl', this.root).text(v.Titre.replace(/&amp;/g, '&'));
    if (v.hasOwnProperty('Page') && v.Page.hasOwnProperty('Lien')) {
      $('.vtopurl', this.root).attr('href', v.Page.Lien);
    }
    if (v.hasOwnProperty('PDF')) {
      $('.vtoPDF', this.root).attr('href', v.PDF.Lien).show();
    } else {
      $('.vtoPDF', this.root).hide();      
    }
    // TODO
    // gérere Fichier avec embedding à la volée
    if (v.hasOwnProperty('Presentation') && v.Presentation !== null) {
      $('.vtoppres', this.root).html(v.Presentation.replace(/&lt;/g, '<').replace(/&gt;/g, '>'));
    } else {
      $('.vtoppres', this.root).html('');
    }
    $('.vtopajout', this.root).html(this.formatDate(v.Ajout));
    $('.vtoppub', this.root).html(this.formatDate(v.Publication));
    if (v.hasOwnProperty('Duree')) {
      $('.vtopduree', this.root).html(this.formatDuree(v.Duree));
      $('.vtopduree', this.root).parent().show();
    } else {
      $('.vtopduree', this.root).parent().hide(); 
    }
    if (v.hasOwnProperty('Tag')) {
      $('.vtoptag', this.root).html(
        v.Tag.reduce( (a, cur) => a +  '<span class="tag">' + cur + '</span> ', '')
      );
    } else {
      $('.vtoptag', this.root).html('');
    }
    this.CUR = i;
    $('.vtopcur', this.root).text(this.CUR + 1);
    if (this.CUR === 0) {
      $('.vtopavant', this.root).hide();     
    } else {
      $('.vtopavant', this.root).show();
    }
    if (this.CUR === this.BD.length - 1) {
      $('.vtopapres', this.root).hide();     
    } else {
      $('.vtopapres', this.root).show();
    }    
  }

  terminerVideo() {
    $('.vtopaction', this.root).prop( "disabled", false );
  }

  disparition() {
    $('.vtopanim', this.root).removeClass('appearin');
    $('.vtopanim', this.root).addClass('appearout');
    $('.vtopaction', this.root).prop( "disabled", true );
  }

  apparition() {
    $('.vtopanim', this.root).removeClass('appearout');    
    $('.vtopanim', this.root).addClass('appearin');
    $('.vtopanim', this.root).one('animationend', this.terminerVideo.bind(this));    
  }

  choisirVideoAuHasard() {
    var i = Math.floor(Math.random() * this.BD.length);
    if (this.BD.length > 1) {
      while (i === this.CUR) { i = Math.floor(Math.random() * this.BD.length) };
    }
    this.installerVideo(i);
    this.apparition();
  }

  choisirVideoPrecedente() {
    this.installerVideo(this.CUR - 1);    
    this.apparition();
  }

  choisirVideoSuivante() {
    this.installerVideo(this.CUR + 1);
    this.apparition();
  }

  changerVideo() {
    this.disparition();
    $('.vtopanim', this.root).one('animationend', this.choisirVideoAuHasard.bind(this));
  }

  videoPrecedente() {
    if (this.CUR > 1) {
      this.disparition();
      $('.vtopanim', this.root).one('animationend', this.choisirVideoPrecedente.bind(this));
    }
  }

  videoSuivante() {
    if ((this.CUR + 1) < this.BD.length) {
      this.disparition();      
      $('.vtopanim', this.root).one('animationend', this.choisirVideoSuivante.bind(this));
    }
  }
}


(function () {
    
  function init () {
    if ($('#vtop').length > 0) { 
      new JukeBox($('#vtop').get(0), Videos);
    }
    if ($('#atop').length > 0) {
      new JukeBox($('#atop').get(0), Articles);
    }
    // icon installation    
    $('*[data-cadoc]').each(
      function() {
        var n = $(this),
            h = n.attr('href');
        $(' <a href="' + 'https://www.cadoc.fr/cslv85/archives' + h + '"><img src="img/pdf.png" width="32px" alt="PDF" style="vertical-align:text-bottom;margin-left:10px"/></a>')
            .insertAfter(n);
      }
    );    
    // mail installation    
    $('a[data-mail1]').each(
      function() {
        var n = $(this),
            s1 = n.attr('data-mail1'),
            s2 = n.attr('data-mail2'),
            subject = n.attr('data-subject'),
            contact = n.attr('data-contact'),
            text = n.attr('data-text');
        if (subject) {
          n.attr('href', 'mailto:' + s1 + '@' + s2 + '?subject=' + subject);        
        } else {
          n.text(s1 + '@' + s2);
          if (contact) {
            n.attr('href', 'mailto:' + s1 + '@' + s2 + '?subject=' + contact);
          } else {
            n.attr('href', 'mailto:' + s1 + '@' + s2);
          }
        }
        if (text && text === 'copy') {
          n.text(s1 + '@' + s2);
        }
      }      
    )
  }

  jQuery(function() { init(); });
}());
  
