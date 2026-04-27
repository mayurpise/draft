/* ============================================================
   Blog post share buttons
   ============================================================
   Wires up share/copy buttons rendered in the post-share block.
   Uses canonical URL + document.title for share content.
   ============================================================ */
(function () {
    'use strict';

    var share = document.querySelector('.post-share');
    if (!share) return;

    var canonical = document.querySelector('link[rel="canonical"]');
    var url = canonical ? canonical.href : window.location.href;
    var title = document.title.replace(/\s+—\s+Draft Blog\s*$/, '').trim();

    var enc = encodeURIComponent;

    var targets = {
        linkedin: 'https://www.linkedin.com/sharing/share-offsite/?url=' + enc(url),
        x:        'https://twitter.com/intent/tweet?text=' + enc(title) + '&url=' + enc(url),
        hn:       'https://news.ycombinator.com/submitlink?u=' + enc(url) + '&t=' + enc(title)
    };

    share.querySelectorAll('.share-btn').forEach(function (btn) {
        var net = btn.getAttribute('data-net');

        if (net === 'copy') {
            btn.addEventListener('click', function () {
                var done = function () {
                    var label = btn.querySelector('.share-btn-label');
                    var orig = label ? label.textContent : '';
                    btn.classList.add('copied');
                    if (label) label.textContent = 'Copied';
                    setTimeout(function () {
                        btn.classList.remove('copied');
                        if (label) label.textContent = orig;
                    }, 1800);
                };
                if (navigator.clipboard && navigator.clipboard.writeText) {
                    navigator.clipboard.writeText(url).then(done, done);
                } else {
                    var ta = document.createElement('textarea');
                    ta.value = url;
                    ta.setAttribute('readonly', '');
                    ta.style.position = 'absolute';
                    ta.style.left = '-9999px';
                    document.body.appendChild(ta);
                    ta.select();
                    try { document.execCommand('copy'); } catch (_) { /* no-op */ }
                    document.body.removeChild(ta);
                    done();
                }
            });
            return;
        }

        var href = targets[net];
        if (!href) return;
        btn.addEventListener('click', function () {
            window.open(href, 'share-' + net,
                'noopener,noreferrer,width=600,height=520,resizable=yes,scrollbars=yes');
        });
    });
})();
