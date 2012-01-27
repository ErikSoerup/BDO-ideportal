// shows this is run through jsbin & you can edit
(function () {
  if (window.location.hash == '#noedit') return;
  var ie = (!+"\v1");

  function set(el, props, hover) {
    for (prop in props) {
      el.style[prop] = props[prop];
    }
  }

  function hide() {
    set(el, { opacity: '0' });
  }

  

  document.body.appendChild(el);
  setTimeout(hide, 2000);
  var moveTimer = null;

  if (document.addEventListener) {
    document.addEventListener('mousemove', show, false);
  } else {
    document.attachEvent('onmousemove', show);
  }

  function show() {
    if (!ie && (el.style.opacity*1) == 0) { // TODO IE compat
      el.style.opacity = 1;
    } else if (ie) {
      set(el, { display: 'block', opacity: '1' });
    }
    clearTimeout(moveTimer);
    moveTimer = setTimeout(hide, 2000);
  }
})();