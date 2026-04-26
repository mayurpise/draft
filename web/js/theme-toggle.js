/* ============================================================
   Theme toggle — light / dark
   ============================================================
   Honors `prefers-color-scheme` on first visit, persists user
   choice in localStorage. Sets `data-theme` on <html>.
   ============================================================ */
(function () {
    'use strict';
    var KEY = 'draft-theme';

    function applyTheme(theme) {
        if (theme === 'dark') {
            document.documentElement.setAttribute('data-theme', 'dark');
        } else {
            document.documentElement.removeAttribute('data-theme');
        }
    }

    function preferredTheme() {
        var stored = null;
        try { stored = localStorage.getItem(KEY); } catch (_) { /* no-op */ }
        if (stored === 'dark' || stored === 'light') return stored;
        if (window.matchMedia &&
            window.matchMedia('(prefers-color-scheme: dark)').matches) {
            return 'dark';
        }
        return 'light';
    }

    function toggle() {
        var current = document.documentElement.getAttribute('data-theme') === 'dark'
            ? 'dark' : 'light';
        var next    = current === 'dark' ? 'light' : 'dark';
        applyTheme(next);
        try { localStorage.setItem(KEY, next); } catch (_) { /* no-op */ }
    }

    function injectButton() {
        if (document.querySelector('.theme-toggle')) return;
        var btn = document.createElement('button');
        btn.className = 'theme-toggle';
        btn.setAttribute('type', 'button');
        btn.setAttribute('aria-label', 'Toggle dark mode');
        btn.setAttribute('title', 'Toggle theme');
        btn.innerHTML =
            '<svg class="icon-moon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>' +
            '<svg class="icon-sun"  viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="4"/><path d="M12 2v2"/><path d="M12 20v2"/><path d="M4.93 4.93l1.41 1.41"/><path d="M17.66 17.66l1.41 1.41"/><path d="M2 12h2"/><path d="M20 12h2"/><path d="M4.93 19.07l1.41-1.41"/><path d="M17.66 6.34l1.41-1.41"/></svg>';
        btn.addEventListener('click', toggle);
        document.body.appendChild(btn);
    }

    // Apply theme as early as possible to avoid flash
    applyTheme(preferredTheme());

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', injectButton);
    } else {
        injectButton();
    }

    // Honor system theme changes if user hasn't chosen explicitly
    if (window.matchMedia) {
        try {
            window.matchMedia('(prefers-color-scheme: dark)')
                .addEventListener('change', function (e) {
                    var stored = null;
                    try { stored = localStorage.getItem(KEY); } catch (_) { /* no-op */ }
                    if (stored === 'dark' || stored === 'light') return; // user-picked
                    applyTheme(e.matches ? 'dark' : 'light');
                });
        } catch (_) { /* old browsers */ }
    }
})();
