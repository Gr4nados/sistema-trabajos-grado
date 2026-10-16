// app.js - Comportamiento del navegador (RNF-02): menu lateral en celular y mensajes que se desvanecen.
(function () {
  var cuerpo = document.body;

  document.addEventListener('click', function (e) {
    if (e.target.closest('[data-menu]')) {
      cuerpo.classList.toggle('menu-abierto');
    } else if (e.target.closest('[data-cerrar]')) {
      cuerpo.classList.remove('menu-abierto');
    }
  });

  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') cuerpo.classList.remove('menu-abierto');
  });

  // Los mensajes de exito se ocultan solos; los de error se quedan.
  document.querySelectorAll('.exito').forEach(function (m) {
    setTimeout(function () {
      m.classList.add('oculto');
      setTimeout(function () { m.remove(); }, 600);
    }, 6000);
  });
})();
