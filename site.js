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