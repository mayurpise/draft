/* ============================================================
   DRAFT EBOOK — Navigation & Interactivity
   ============================================================ */

// Chapter manifest — order matters
const CHAPTERS = [
    { id: 'what-is-draft',              file: '00-what-is-draft.html',              title: 'What is Draft?',                  part: null,                    readTime: '2 min'  },
    { id: 'the-problem',                file: '01-the-problem.html',                title: 'The Problem',                     part: 'I. Foundation',         readTime: '8 min'  },
    { id: 'context-driven-development', file: '02-context-driven-development.html', title: 'Context-Driven Development',      part: 'I. Foundation',         readTime: '10 min' },
    { id: 'getting-started',            file: '03-getting-started.html',            title: 'Getting Started',                 part: 'I. Foundation',         readTime: '8 min'  },
    { id: 'context-tiering',            file: '04-context-tiering.html',            title: 'Context Tiering',                 part: 'II. How Draft Thinks',  readTime: '6 min'  },
    { id: 'agent-system',               file: '05-agent-system.html',               title: 'The Agent System',                part: 'II. How Draft Thinks',  readTime: '5 min'  },
    { id: 'signal-classification',      file: '06-signal-classification.html',      title: 'Signal Classification',           part: 'II. How Draft Thinks',  readTime: '5 min'  },
    { id: 'incremental-refresh',        file: '07-incremental-refresh.html',        title: 'Incremental Refresh',             part: 'II. How Draft Thinks',  readTime: '4 min'  },
    { id: 'specs-and-plans',            file: '08-specs-and-plans.html',            title: 'Specs & Plans',                   part: 'III. Track Lifecycle',   readTime: '6 min'  },
    { id: 'implementation',             file: '09-implementation.html',             title: 'Implementation',                  part: 'III. Track Lifecycle',   readTime: '6 min'  },
    { id: 'review-pipeline',            file: '10-review-pipeline.html',            title: 'Review Pipeline',                 part: 'III. Track Lifecycle',   readTime: '6 min'  },
    { id: 'managing-tracks',            file: '11-managing-tracks.html',            title: 'Managing Tracks',                 part: 'III. Track Lifecycle',   readTime: '4 min'  },
    { id: 'deep-review',                file: '12-deep-review.html',                title: 'Deep Review',                     part: 'IV. Quality',           readTime: '5 min'  },
    { id: 'bug-hunt',                   file: '13-bug-hunt.html',                   title: 'Bug Hunt',                        part: 'IV. Quality',           readTime: '6 min'  },
    { id: 'coverage',                   file: '14-coverage.html',                   title: 'Coverage',                        part: 'IV. Quality',           readTime: '5 min'  },
    { id: 'pattern-learning',           file: '15-pattern-learning.html',           title: 'Pattern Learning',                part: 'IV. Quality',           readTime: '5 min'  },
    { id: 'decomposition',              file: '16-decomposition.html',              title: 'Decomposition',                   part: 'V. Architecture',       readTime: '4 min'  },
    { id: 'adrs',                       file: '17-adrs.html',                       title: 'Architecture Decision Records',   part: 'V. Architecture',       readTime: '3 min'  },
    { id: 'monorepo-federation',        file: '18-monorepo-federation.html',        title: 'Monorepo Federation',             part: 'VI. Enterprise',        readTime: '4 min'  },
    { id: 'jira-integration',           file: '19-jira-integration.html',           title: 'Jira Integration',                part: 'VI. Enterprise',        readTime: '3 min'  },
    { id: 'multi-ide-support',          file: '20-multi-ide-support.html',          title: 'Multi-IDE Support',               part: 'VI. Enterprise',        readTime: '4 min'  },
    { id: 'philosophy-references',      file: '21-philosophy-references.html',      title: 'Philosophy & References',         part: 'VII. Closing',          readTime: '6 min'  },
    { id: 'command-reference',          file: 'appendix-a-command-reference.html',  title: 'Command Reference',               part: 'Appendix',              readTime: null     },
    { id: 'file-reference',             file: 'appendix-b-file-reference.html',     title: 'File Reference',                  part: 'Appendix',              readTime: null     },
];

// Chapter descriptions for SEO meta tags
const CHAPTER_DESCRIPTIONS = {
    'what-is-draft':              'What Draft is, what it is not, who it is for, and what you get — 17 commands and 5 specialized agents for structured AI development.',
    'the-problem':                'Why AI coding assistants produce wrong code without structure — the gap between speed and correctness, and why better prompting is not the answer.',
    'context-driven-development': 'The Context-Driven Development methodology — every decision grounded in explicit, versioned, reviewable documents rather than implicit assumptions.',
    'getting-started':            'Install Draft and run your first commands in five minutes. Set up architecture discovery, create a track, and start implementing.',
    'context-tiering':            'How Draft organizes project context into three tiers — always-loaded profiles, working memory, and deep storage — like CPU memory hierarchy.',
    'agent-system':               'Five specialized agents — Architect, Debugger, Planner, RCA, and Reviewer — each with behavioral protocols tuned for their domain.',
    'signal-classification':      'How Draft classifies source files into 11 signal categories to determine which architecture sections get deep treatment, brief mention, or skip.',
    'incremental-refresh':        'How Draft detects changes and updates only what has drifted — freshness hashing, signal drift detection, and targeted regeneration.',
    'specs-and-plans':            'Collaborative spec intake and phased plan generation — requirements to specification to implementation plan, reviewed before code exists.',
    'implementation':             'Task-by-task implementation with TDD enforcement — RED, GREEN, REFACTOR cycles with architecture checkpoints and production robustness patterns.',
    'review-pipeline':            'Three-stage code review pipeline — automated validation, spec compliance checking, and code quality analysis with STRIDE threat modeling.',
    'managing-tracks':            'Track lifecycle management — status markers, parallel tracks, blocked state handling, and git-aware rollback.',
    'deep-review':                'Production-grade deep review with ACID compliance audits — atomicity, isolation, durability, idempotency, resilience, and observability checks.',
    'bug-hunt':                   '14-dimension bug hunting sweep — from null safety to concurrency, security to algorithmic complexity. Only HIGH/CONFIRMED confidence reported.',
    'coverage':                   'Spec-to-implementation coverage analysis — gap identification, untested paths, and target enforcement at 95%+ coverage.',
    'pattern-learning':           'How Draft detects codebase patterns, records them to guardrails, and applies learned conventions to future work.',
    'decomposition':              'Breaking large features into independently shippable sub-tasks — tree decomposition with dependency ordering and blast radius scoping.',
    'adrs':                       'Architecture Decision Records — structured decision capture with context, rationale, consequences, and lifecycle management.',
    'monorepo-federation':        'Context federation across monorepo services — per-service draft directories with shared root context and service aggregation.',
    'jira-integration':           'Mapping Draft tracks to Jira issues — preview before creation, epic/story/sub-task mapping, and bidirectional sync.',
    'multi-ide-support':          'How Draft works across Claude Code, Copilot, Cursor, Gemini, and Antigravity IDE — platform-specific syntax transforms.',
    'philosophy-references':      'The philosophical foundations of Context-Driven Development — structured development, quality gates, incremental refinement.',
    'command-reference':          'Complete reference for all 17 Draft commands — usage, options, examples, and output for each slash command.',
    'file-reference':             'Complete reference for all Draft-generated files — architecture.md, .ai-context.md, .ai-profile.md, specs, plans, and state files.',
};

// State
let currentChapter = null;
let chapterCache = {};

// ============================================================
// INITIALIZATION
// ============================================================
document.addEventListener('DOMContentLoaded', () => {
    initRouter();
    initSidebar();
    initProgress();
    initSearch();
});

// ============================================================
// ROUTER — hash-based chapter loading
// ============================================================
function initRouter() {
    window.addEventListener('hashchange', handleRoute);
    handleRoute();
}

function handleRoute() {
    const hash = location.hash.slice(1) || 'what-is-draft';
    const chapter = CHAPTERS.find(c => c.id === hash);

    if (chapter) {
        loadChapter(chapter);
    } else {
        // Fallback to first chapter
        location.hash = '#what-is-draft';
    }
}

async function loadChapter(chapter) {
    const content = document.getElementById('chapter-content');
    const topbarChapter = document.getElementById('topbar-chapter-title');

    // Update topbar
    if (topbarChapter) {
        topbarChapter.textContent = chapter.title;
    }

    // Show loading
    content.innerHTML = '<div class="chapter-loading">Loading chapter</div>';

    try {
        let html;
        if (chapterCache[chapter.id]) {
            html = chapterCache[chapter.id];
        } else {
            const resp = await fetch('chapters/' + chapter.file);
            if (!resp.ok) throw new Error('Chapter not found');
            html = await resp.text();
            chapterCache[chapter.id] = html;
        }

        content.innerHTML = html;
        buildChapterNav(chapter);
        buildPageTOC();
        updateSidebarActive(chapter.id);
        currentChapter = chapter;

        // Scroll to top of content
        window.scrollTo(0, 0);

        // Update document title and meta tags for SEO
        document.title = chapter.title + ' — Draft Book';
        updateMeta(chapter);

    } catch (err) {
        content.innerHTML = `
            <div class="chapter-wrapper">
                <h1>Chapter Not Found</h1>
                <p>This chapter hasn't been written yet. Use the sidebar to navigate to an available chapter.</p>
            </div>`;
    }

    // Close mobile sidebar
    closeMobileSidebar();
}

// ============================================================
// DYNAMIC META TAGS (SEO for SPA chapter navigation)
// ============================================================
function updateMeta(chapter) {
    const desc = CHAPTER_DESCRIPTIONS[chapter.id] || '';
    const title = chapter.title + ' — Draft Book';
    const url = 'https://getdraft.dev/book/#' + chapter.id;

    setMeta('name', 'description', desc);
    setMeta('property', 'og:title', title);
    setMeta('property', 'og:description', desc);
    setMeta('property', 'og:url', url);
    setMeta('name', 'twitter:title', title);
    setMeta('name', 'twitter:description', desc);

    const canonical = document.querySelector('link[rel="canonical"]');
    if (canonical) canonical.href = url;
}

function setMeta(attr, key, value) {
    let el = document.querySelector(`meta[${attr}="${key}"]`);
    if (!el) {
        el = document.createElement('meta');
        el.setAttribute(attr, key);
        document.head.appendChild(el);
    }
    el.setAttribute('content', value);
}

// ============================================================
// CHAPTER NAVIGATION (prev/next)
// ============================================================
function buildChapterNav(chapter) {
    const idx = CHAPTERS.findIndex(c => c.id === chapter.id);
    const prev = idx > 0 ? CHAPTERS[idx - 1] : null;
    const next = idx < CHAPTERS.length - 1 ? CHAPTERS[idx + 1] : null;

    const wrapper = document.querySelector('.chapter-wrapper');
    if (!wrapper) return;

    // Remove any existing nav
    const existingNav = wrapper.querySelector('.chapter-nav');
    if (existingNav) existingNav.remove();

    const nav = document.createElement('nav');
    nav.className = 'chapter-nav';

    if (prev) {
        nav.innerHTML += `
            <a href="#${prev.id}" class="chapter-nav-link chapter-nav-link--prev">
                <span class="chapter-nav-label">&larr; Previous</span>
                <span class="chapter-nav-title">${prev.title}</span>
            </a>`;
    } else {
        nav.innerHTML += '<div></div>';
    }

    if (next) {
        nav.innerHTML += `
            <a href="#${next.id}" class="chapter-nav-link chapter-nav-link--next">
                <span class="chapter-nav-label">Next &rarr;</span>
                <span class="chapter-nav-title">${next.title}</span>
            </a>`;
    } else {
        nav.innerHTML += '<div></div>';
    }

    wrapper.appendChild(nav);
}

// ============================================================
// ON THIS PAGE (mini-TOC from headings)
// ============================================================
function buildPageTOC() {
    const tocContainer = document.getElementById('page-toc-list');
    if (!tocContainer) return;

    const headings = document.querySelectorAll('.chapter-wrapper h2, .chapter-wrapper h3');
    tocContainer.innerHTML = '';

    if (headings.length === 0) {
        document.querySelector('.page-toc').style.display = 'none';
        return;
    }

    document.querySelector('.page-toc').style.display = '';

    headings.forEach(h => {
        // Ensure heading has an id
        if (!h.id) {
            h.id = h.textContent.toLowerCase()
                .replace(/[^a-z0-9]+/g, '-')
                .replace(/^-|-$/g, '');
        }

        const item = document.createElement('a');
        item.href = '#' + h.id;
        item.className = 'page-toc-item' + (h.tagName === 'H3' ? ' page-toc-item--h3' : '');
        item.textContent = h.textContent;
        item.addEventListener('click', (e) => {
            e.preventDefault();
            h.scrollIntoView({ behavior: 'smooth', block: 'start' });
        });

        tocContainer.appendChild(item);
    });

    // Observe headings for active state
    observeHeadings(headings);
}

function observeHeadings(headings) {
    const tocItems = document.querySelectorAll('.page-toc-item');

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                tocItems.forEach(item => item.classList.remove('active'));
                const activeItem = document.querySelector(`.page-toc-item[href="#${entry.target.id}"]`);
                if (activeItem) activeItem.classList.add('active');
            }
        });
    }, { rootMargin: '-80px 0px -70% 0px', threshold: 0 });

    headings.forEach(h => observer.observe(h));
}

// ============================================================
// SIDEBAR
// ============================================================
function initSidebar() {
    const toggle = document.getElementById('sidebar-toggle');
    const backdrop = document.getElementById('sidebar-backdrop');

    if (toggle) {
        toggle.addEventListener('click', toggleMobileSidebar);
    }

    if (backdrop) {
        backdrop.addEventListener('click', closeMobileSidebar);
    }
}

function toggleMobileSidebar() {
    const sidebar = document.getElementById('book-sidebar');
    const backdrop = document.getElementById('sidebar-backdrop');

    sidebar.classList.toggle('open');
    backdrop.classList.toggle('visible');
}

function closeMobileSidebar() {
    const sidebar = document.getElementById('book-sidebar');
    const backdrop = document.getElementById('sidebar-backdrop');

    if (sidebar) sidebar.classList.remove('open');
    if (backdrop) backdrop.classList.remove('visible');
}

function updateSidebarActive(chapterId) {
    document.querySelectorAll('.sidebar-chapter').forEach(el => {
        el.classList.toggle('active', el.dataset.chapter === chapterId);
    });

    // Scroll active item into view in sidebar
    const active = document.querySelector('.sidebar-chapter.active');
    if (active) {
        active.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }
}

// ============================================================
// READING PROGRESS
// ============================================================
function initProgress() {
    const bar = document.getElementById('reading-progress');
    if (!bar) return;

    window.addEventListener('scroll', () => {
        const winH = window.innerHeight;
        const docH = document.documentElement.scrollHeight;
        const scrolled = window.scrollY;
        const pct = Math.min(100, (scrolled / (docH - winH)) * 100);
        bar.style.width = pct + '%';
    }, { passive: true });
}

// ============================================================
// SIDEBAR SEARCH
// ============================================================
function initSearch() {
    const input = document.getElementById('sidebar-search-input');
    if (!input) return;

    input.addEventListener('input', () => {
        const query = input.value.toLowerCase().trim();
        document.querySelectorAll('.sidebar-chapter').forEach(el => {
            const text = el.textContent.toLowerCase();
            el.style.display = query === '' || text.includes(query) ? '' : 'none';
        });

        // Show/hide part titles
        document.querySelectorAll('.sidebar-part').forEach(part => {
            const visibleChapters = part.querySelectorAll('.sidebar-chapter:not([style*="display: none"])');
            part.style.display = visibleChapters.length === 0 && query !== '' ? 'none' : '';
        });
    });
}

// ============================================================
// KEYBOARD NAVIGATION
// ============================================================
document.addEventListener('keydown', (e) => {
    // Don't capture when typing in search
    if (e.target.tagName === 'INPUT') return;

    const idx = currentChapter ? CHAPTERS.findIndex(c => c.id === currentChapter.id) : -1;

    if (e.key === 'ArrowLeft' && idx > 0) {
        location.hash = '#' + CHAPTERS[idx - 1].id;
    } else if (e.key === 'ArrowRight' && idx < CHAPTERS.length - 1) {
        location.hash = '#' + CHAPTERS[idx + 1].id;
    }
});
