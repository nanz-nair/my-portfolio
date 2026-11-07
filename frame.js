/* Frame glow: passes the cursor position to CSS (--pointer-x / --pointer-y on
   <html>) so the gradient frame's glow follows the mouse. Only for devices with
   a mouse; touch screens keep the glow centred. */
(function () {
  if (!window.matchMedia('(hover: hover) and (pointer: fine)').matches) return;

  var root = document.documentElement;
  var x = 0;
  var y = 0;
  var queued = false;

  function update() {
    root.style.setProperty('--pointer-x', x + 'px');
    root.style.setProperty('--pointer-y', y + 'px');
    queued = false;
  }

  window.addEventListener('pointermove', function (event) {
    x = event.clientX;
    y = event.clientY;
    if (!queued) {
      queued = true;
      window.requestAnimationFrame(update);
    }
  }, { passive: true });
})();
