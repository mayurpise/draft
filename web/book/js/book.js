/* ============================================================
   DRAFT EBOOK — Page Interactivity (static page routing)
   ============================================================ */

// Chapter manifest — for keyboard navigation and sidebar search
const CHAPTERS = [
    { id: 'what-is-draft',              title: 'What is Draft?' },
    { id: 'the-problem',                title: 'The Problem' },
    { id: 'context-driven-development', title: 'Context-Driven Development' },
    { id: 'getting-started',            title: 'Getting Started' },
    { id: 'context-tiering',            title: 'Context Tiering' },
    { id: 'agent-system',               title: 'The Agent System' },
    { id: 'signal-classification',      title: 'Signal Classification' },
    { id: 'incremental-refresh',        title: 'Incremental Refresh' },
    { id: 'specs-and-plans',            title: 'Specs & Plans' },
    { id: 'implementation',             title: 'Implementation' },
    { id: 'review-pipeline',            title: 'Review Pipeline' },
    { id: 'managing-tracks',            title: 'Managing Tracks' },
    { id: 'deep-review',               title: 'Deep Review' },
    { id: 'bug-hunt',                   title: 'Bug Hunt' },
    { id: 'coverage',                   title: 'Coverage' },
    { id: 'pattern-learning',           title: 'Pattern Learning' },
    { id: 'decomposition',              title: 'Decomposition' },
    { id: 'adrs',                       title: 'Architecture Decision Records' },
    { id: 'monorepo-federation',        title: 'Monorepo Federation' },
    { id: 'jira-integration',           title: 'Jira Integration' },
    { id: 'multi-ide-support',          title: 'Multi-IDE Support' },
    { id: 'philosophy-references',      title: 'Philosophy & References' },
    { id: 'command-reference',          title: 'Command Reference' },
    { id: 'file-reference',             title: 'File Reference' },
];

// ============================================================
// INITIALIZATION
// ============================================================
document.addEventListener('DOMContentLoaded', () => {
    initSidebar();
    initProgress();
    initSearch();
    buildPageTOC();
});

// ============================================================
// ON THIS PAGE (mini-TOC from headings)
// ============================================================
function buildPageTOC() {
    const tocContainer = document.getElementById('page-toc-list');
    if (!tocContainer) return;

    const headings = document.querySelectorAll('.chapter-wrapper h2, .chapter-wrapper h3');
    tocContainer.innerHTML = '';

    if (headings.length === 0) {
        const toc = document.querySelector('.page-toc');
        if (toc) toc.style.display = 'none';
        return;
    }

    const toc = document.querySelector('.page-toc');
    if (toc) toc.style.display = '';

    headings.forEach(h => {
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

    // Close sidebar when a chapter link is clicked (mobile)
    document.querySelectorAll('.sidebar-chapter').forEach(link => {
        link.addEventListener('click', () => {
            if (window.innerWidth <= 768) {
                closeMobileSidebar();
            }
        });
    });

    // Swipe-to-close on the sidebar
    initSidebarSwipe();
}

function toggleMobileSidebar() {
    const sidebar = document.getElementById('book-sidebar');
    const backdrop = document.getElementById('sidebar-backdrop');
    const isOpen = sidebar.classList.toggle('open');

    backdrop.classList.toggle('visible', isOpen);
    document.body.style.overflow = isOpen ? 'hidden' : '';
}

function closeMobileSidebar() {
    const sidebar = document.getElementById('book-sidebar');
    const backdrop = document.getElementById('sidebar-backdrop');

    if (sidebar) sidebar.classList.remove('open');
    if (backdrop) backdrop.classList.remove('visible');
    document.body.style.overflow = '';
}

function initSidebarSwipe() {
    const sidebar = document.getElementById('book-sidebar');
    if (!sidebar) return;

    let startX = 0;
    sidebar.addEventListener('touchstart', (e) => {
        startX = e.touches[0].clientX;
    }, { passive: true });

    sidebar.addEventListener('touchend', (e) => {
        const dx = e.changedTouches[0].clientX - startX;
        if (dx < -60) closeMobileSidebar(); // swipe left to close
    }, { passive: true });
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
    if (e.target.tagName === 'INPUT') return;

    const currentId = document.body.dataset.chapter;
    if (!currentId) return;

    const idx = CHAPTERS.findIndex(c => c.id === currentId);
    if (idx === -1) return;

    if (e.key === 'ArrowLeft' && idx > 0) {
        location.href = '../' + CHAPTERS[idx - 1].id + '/';
    } else if (e.key === 'ArrowRight' && idx < CHAPTERS.length - 1) {
        location.href = '../' + CHAPTERS[idx + 1].id + '/';
    }
});
