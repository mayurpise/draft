/* ============================================================
   Playground — interactive graph query demo (pre-rendered)
   ============================================================
   Tab-switcher with 6 fixtures showing real-shaped JSON output
   from each graph query mode. No live engine; output is static
   but accurate per docs/shared/graph-query.md schema.
   ============================================================ */
(function () {
    'use strict';

    var fixtures = {
        impact: {
            cmd: 'graph --query --file core/methodology.md --mode impact',
            json: {
                target: 'core/methodology.md',
                impact: {
                    files: 31,
                    modules: 4,
                    affected_modules: ['skills', 'integrations', 'web', 'tests'],
                    by_category: { code: 14, test: 8, doc: 7, config: 2 },
                    files_by_depth: {
                        '1': [
                            'skills/init/SKILL.md',
                            'skills/new-track/SKILL.md',
                            'skills/implement/SKILL.md'
                        ],
                        '2': [
                            'integrations/copilot/.github/copilot-instructions.md',
                            'web/index.html'
                        ],
                        '3': ['tests/test-skill-frontmatter.sh']
                    }
                },
                warning: null
            }
        },
        callers: {
            cmd: 'graph --query --symbol queryImpact --mode callers',
            json: {
                target: 'queryImpact',
                callers: [
                    {
                        func: 'query',
                        file: 'graph/src/query.js',
                        module: 'graph',
                        line: 27,
                        kind: 'ts-call',
                        confidence: 'direct'
                    }
                ],
                total: 1,
                by_module: { graph: 1 },
                note: 'intra-file call edges only; cross-file resolution requires type information'
            }
        },
        hotspots: {
            cmd: 'graph --query --mode hotspots',
            json: {
                hotspots: [
                    { id: 'skills/init/SKILL.md',           module: 'skills', lines: 3267, fanIn: 22 },
                    { id: 'core/methodology.md',            module: 'core',   lines: 1117, fanIn: 28 },
                    { id: 'skills/new-track/SKILL.md',      module: 'skills', lines:  843, fanIn: 14 },
                    { id: 'skills/review/SKILL.md',         module: 'skills', lines:  827, fanIn: 12 },
                    { id: 'skills/implement/SKILL.md',      module: 'skills', lines:  693, fanIn: 18 },
                    { id: 'skills/index/SKILL.md',          module: 'skills', lines:  878, fanIn:  8 },
                    { id: 'skills/decompose/SKILL.md',      module: 'skills', lines:  431, fanIn: 11 },
                    { id: 'core/shared/graph-query.md',     module: 'core',   lines:  234, fanIn: 16 }
                ]
            }
        },
        cycles: {
            cmd: 'graph --query --mode cycles',
            json: {
                cycles: [],
                count: 0,
                message: 'No circular dependencies detected.'
            }
        },
        modules: {
            cmd: 'graph --query --mode modules',
            json: {
                modules: [
                    { kind: 'node', id: 'skills',       sizeKB: 412 },
                    { kind: 'node', id: 'core',         sizeKB: 198 },
                    { kind: 'node', id: 'graph',        sizeKB: 156 },
                    { kind: 'node', id: 'scripts',      sizeKB:  47 },
                    { kind: 'node', id: 'tests',        sizeKB:  38 },
                    { kind: 'node', id: 'integrations', sizeKB: 524 }
                ],
                dependencies: [
                    { kind: 'edge', source: 'skills',       target: 'core',   weight: 178 },
                    { kind: 'edge', source: 'integrations', target: 'skills', weight:  56 },
                    { kind: 'edge', source: 'integrations', target: 'core',   weight:  38 },
                    { kind: 'edge', source: 'tests',        target: 'scripts', weight: 24 },
                    { kind: 'edge', source: 'scripts',      target: 'graph',  weight:  9 }
                ],
                cycles: [],
                summary: {
                    modules: 6,
                    edges:   5,
                    cycles:  0,
                    hub_modules: [
                        { module: 'core',   dependents_weight: 216 },
                        { module: 'skills', dependents_weight:  56 },
                        { module: 'graph',  dependents_weight:   9 }
                    ]
                }
            }
        },
        mermaid: {
            cmd: 'graph --query --mode mermaid',
            // Mermaid mode emits markdown text, not JSON. Show a fenced block.
            text:
                '## Module Dependencies\n\n' +
                '```mermaid\n' +
                'graph LR\n' +
                '    integrations --> skills\n' +
                '    integrations --> core\n' +
                '    skills --> core\n' +
                '    tests --> scripts\n' +
                '    scripts --> graph\n' +
                '    classDef hub fill:#7c3aed,stroke:#5b21b6,color:#fff\n' +
                '    class core hub\n' +
                '```\n\n' +
                '## Proto Service Map\n\n' +
                '```mermaid\n' +
                'graph TD\n' +
                '    %% No proto files in this repo —\n' +
                '    %% map is empty\n' +
                '```\n'
        }
    };

    /* ─── Pretty-print JSON with syntax classes for highlighting ───── */
    function escapeHtml(s) {
        return String(s)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;');
    }

    function colorize(json) {
        var raw = JSON.stringify(json, null, 2);
        // Order matters: strings first (so we don't double-color keys)
        return raw.replace(
            /"([^"\\]|\\.)*"(\s*:)?|\b(true|false)\b|\b(null)\b|-?\b\d+(?:\.\d+)?\b/g,
            function (match, _g1, _g2, bool, nul) {
                if (/^".*"\s*:/.test(match)) {
                    var key = match.replace(/\s*:$/, '');
                    return '<span class="pg-key">' + escapeHtml(key) + '</span>:';
                }
                if (bool) return '<span class="pg-bool">' + match + '</span>';
                if (nul)  return '<span class="pg-null">' + match + '</span>';
                if (match.charAt(0) === '"') return '<span class="pg-str">' + escapeHtml(match) + '</span>';
                return '<span class="pg-num">' + match + '</span>';
            }
        );
    }

    function colorizeMermaid(text) {
        // Highlight fenced ```mermaid blocks differently
        return escapeHtml(text)
            .replace(/^(##\s+.*)$/gm, '<span class="pg-violet">$1</span>')
            .replace(/^(```mermaid)$/gm, '<span class="pg-key">$1</span>')
            .replace(/^(```)$/gm, '<span class="pg-key">$1</span>')
            .replace(/(%%[^\n]*)/g, '<span class="pg-comment">$1</span>')
            .replace(/^(\s+classDef\s+)(\w+)\s+(.+)$/gm,
                '<span class="pg-key">$1</span><span class="pg-bool">$2</span> <span class="pg-str">$3</span>')
            .replace(/^(\s+class\s+)(\w+)\s+(\w+)$/gm,
                '<span class="pg-key">$1</span>$2 <span class="pg-bool">$3</span>');
    }

    function render(tab) {
        var pane    = document.getElementById('playground-output');
        var cmdEl   = document.getElementById('playground-cmd');
        if (!pane || !cmdEl) return;
        var fixture = fixtures[tab];
        if (!fixture) return;
        cmdEl.textContent = fixture.cmd;
        if (fixture.text) {
            pane.innerHTML = colorizeMermaid(fixture.text);
        } else {
            pane.innerHTML = colorize(fixture.json);
        }
    }

    function init() {
        var tabs = document.querySelectorAll('.playground-tab');
        if (!tabs.length) return;

        Array.prototype.forEach.call(tabs, function (tab) {
            tab.addEventListener('click', function () {
                Array.prototype.forEach.call(tabs, function (t) {
                    t.classList.remove('is-active');
                    t.setAttribute('aria-selected', 'false');
                });
                tab.classList.add('is-active');
                tab.setAttribute('aria-selected', 'true');
                render(tab.getAttribute('data-tab'));
            });
        });

        // Initial render
        render('impact');
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
