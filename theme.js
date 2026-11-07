/* Light / dark theme.
   Loaded in <head> so the theme is set before the page paints (no flash).
   A saved choice wins; otherwise follow the system setting. */
(function () {
  var root = document.documentElement;
  var KEY = 'theme';
  var system = window.matchMedia('(prefers-color-scheme: dark)');

  function saved() {
    try {
      var value = localStorage.getItem(KEY);
      return value === 'dark' || value === 'light' ? value : null;
    } catch (e) {
      return null;
    }
  }

  function apply(theme) {
    root.setAttribute('data-theme', theme);
    var button = document.querySelector('.theme-toggle');
    if (button) {
      var dark = theme === 'dark';
      button.setAttribute('aria-pressed', String(dark));
      button.setAttribute('aria-label', dark ? 'Switch to light mode' : 'Switch to dark mode');
    }
  }

  apply(saved() || (system.matches ? 'dark' : 'light'));

  system.addEventListener('change', function (event) {
    if (!saved()) apply(event.matches ? 'dark' : 'light');
  });

  document.addEventListener('DOMContentLoaded', function () {
    var button = document.querySelector('.theme-toggle');
    if (!button) return;
    apply(root.getAttribute('data-theme'));
    button.addEventListener('click', function () {
      var next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
      try {
        localStorage.setItem(KEY, next);
      } catch (e) {}
      apply(next);
    });
  });
})();
