# Documentation Drift Audit — Master Tracker

**Date:** 2026-06-14
**Scope:** Entire documentation surface (website, book HTML + sources, blog, root/project docs, internal docs) audited against the current codebase state.
**Method:** 5 parallel review agents, one per surface, all reconciled against a single verified ground-truth baseline.
**Status:** AUDIT COMPLETE — fixes PENDING (see backlog).

> **Verify-first protocol (mandatory before any fix):** This tracker holds canonical status. Before editing any row, re-confirm the drift still exists against `main` (`git grep` the named string + read context). Generated files (`web/book/*.html`, `integrations/*`) must be fixed at their SOURCE then rebuilt — never hand-edit generated output. Flip already-fixed rows to DONE with evidence instead of re-doing them.

---

## 1. Bottom line

The docs lag the codebase by **two breaking changes** that landed in `3.0.0` + the pending `[Unreleased]`:

1. **`/draft:index` was removed** (folded into scope-aware `/draft:init`) — still documented as a live command across **every** surface.
2. **OKF + committed graph snapshots were removed** (graph is now engine-only) — the website, a blog post, the dogfood `draft/` dir, and internal docs still describe the old "commit your graph files / OKF bundle" model as current.

Plus a family of **stale counts** (commands 34→33, specialists 25/28/22→24, tools 34→32, etc.) and **stale version labels** (v2.8/v2.2 → 3.0).

**~95 confirmed-stale locations across ~30 files.** None block users from installing, but the graph-engine and command-count drift actively misdirects how the product works.

---

## 2. Canonical ground truth (source of truth for ALL fixes)

Every fix must converge on these verified values. Numbers confirmed by direct inspection of `scripts/lib.sh`, `Makefile`, `scripts/tools/`, `core/templates/`, `plugin.json`.

| Fact | Canonical value | Common stale values seen |
|------|-----------------|--------------------------|
| Total skills/commands | **33** | 34, 28 |
| Primary commands | **4** (`init`, `new-track`, `implement`, `review`) | "7 primary" |
| Routers | **5** (`plan`, `ops`, `docs`, `discover`, `jira`) | — |
| Specialist commands | **24** | 25, 28, 22, "20+" |
| Shell tools (`scripts/tools/`, `TOOLS` array) | **32** | 34, 33 |
| Core reference files (`CORE_FILES`) | **62** | 38, 22 |
| Templates (`core/templates/`) | **26** | 20 |
| Registered test suites (Makefile `TEST_SCRIPTS`) | **42** (46 `.sh` on disk: +helpers +3 unregistered) | 44 |
| `build-integrations.sh` size | **657 lines** | "~700" (ok) |
| Generated Copilot file | **~23,600 lines** | "~21,000", "15,000+" |
| `architecture.md` template | **~10-section** graph-primary reference | "25-section" |
| Version | **3.0.0** + pending `[Unreleased]` | v2.8.x, v2.2.0 |
| Graph engine | **`codebase-memory-mcp` by DeusData** (159-lang, 100% local) | "Aether", "tree-sitter knowledge graph" |
| `/draft:index` | **REMOVED** → single scope-aware `/draft:init` | still listed as live |
| OKF (Open Knowledge Format) | **REMOVED** (added 3.0.0, deleted `[Unreleased]`) | "emits OKF bundle by default" |
| Committed graph files | **only `draft/graph/schema.yaml`** (gate marker, `access: engine-live`) | architecture.json, hotspots.jsonl, *.mermaid, okf/ |
| CLI install | `npx @drafthq/draft install <host>` | `/plugin marketplace add` as primary |
| Hosts | claude-code, cursor, codex, opencode (+ Copilot copied file, Gemini `.gemini.md`) | missing codex/opencode |

---

## 3. Workstream rollup dashboard

| # | Surface | Files audited | Confirmed-stale | Worst offender | Fix target |
|---|---------|---------------|-----------------|----------------|------------|
| WS-A | Core website | `web/index.html`, `web/what-is-draft/`, `web/changelog/` | ~18 | `web/index.html` (count + `/draft:index` grid card + OKF helper card) | hand-edit HTML |
| WS-B | Book website (HTML) | `web/book/**` (24 chapters + topic mirrors) | ~52 | ch.18 monorepo-federation (whole chapter on removed cmd) | **fix `book/notebook-sources/*.md` → rebuild** |
| WS-C | Book sources (MD) | `book/notebook-sources/*.md` (24) | ~17 | ch.22/23 are stubs; ch.18 obsolete | edit `.md` source |
| WS-D | Blog | `web/blog/**` (5 posts) | ~12 | `local-graph-engine` (entire thesis = old committed-graph model) | rewrite/retire post |
| WS-E | Root + internal docs | README, CHANGELOG, CLAUDE.md, CONTRIBUTING, bin, `docs/internal/**` | ~16 + dogfood dir | CLAUDE.md (4 stale counts + retired engine CLI) | hand-edit + regen dogfood |

WS-B and WS-C overlap: `web/book/*.html` is generated from `book/notebook-sources/*.md` by `scripts/build-book.sh`. **Fix the markdown sources, then rebuild** — do not hand-edit the HTML.

---

## 4. Prioritized backlog (tiered by user-facing blast radius)

Stable IDs. Each item lists the theme, affected surfaces, and representative locations. Full per-location detail in §5.

### Tier 1 — P0: public-facing, factually wrong about how the product works

| ID | Theme | Surfaces | Effort |
|----|-------|----------|--------|
| **DD-2** | **`/draft:index` removed** — purge every reference; rewrite monorepo-federation chapter to `/draft:init`-per-module | WS-A,B,C,E | High (1 chapter rewrite) |
| **DD-3** | **OKF removed** — purge "Open Knowledge Format" emission/bundle copy | WS-A,B,D,E | Med |
| **DD-4** | **Engine-only graph** — stop describing committed `architecture.json`/`hotspots.jsonl`/`*.mermaid` and "commit your graph files" as current | WS-B,D,E | High (1 blog rewrite) |
| **DD-1** | **Command count 34 → 33** (~26 occurrences) | WS-A,B | Low (mechanical) |
| **DD-5** | **Specialist count → 24** (25/28/22 seen) | WS-A,B,C | Low |
| **DD-7** | **Version labels → 3.0** (v2.8/v2.2 in live UI sections) | WS-A | Low |
| **DD-8** | **Install instructions** — lead with `npx @drafthq/draft install <host>`; add codex/opencode | WS-A,B,C,D | Low |

### Tier 2 — P1: public, secondary accuracy

| ID | Theme | Surfaces | Effort |
|----|-------|----------|--------|
| **DD-6** | `architecture.md` "25-section" → "10-section" | WS-B,C | Low |
| **DD-12** | Command-reference appendix missing `graph`, `upload`, `integrations` | WS-B,C | Low |
| **DD-13** | Book sources ch.22 (command ref) + ch.23 (file ref) are **stubs** — no actual command list / `draft/` layout | WS-C | Med |
| **DD-14** | `web/index.html` command grid: duplicate `/draft:jira`, missing `/draft:graph` + `/draft:upload` | WS-A | Low |
| **DD-16** | Book build-pipeline numbers (skills 25→33, core files 22→62, Copilot 15k→~23.6k) | WS-C | Low |

### Tier 3 — P2: internal / dev-facing

| ID | Theme | Surfaces | Effort |
|----|-------|----------|--------|
| **DD-10** | **CLAUDE.md stale counts + retired graph CLI block** (tools 34→32, core 38→62, templates 20→26, tests 44→42; lines 27–30 reference deleted Node `graph/` engine) | WS-E | Low |
| **DD-11** | **Dogfood `draft/` not regenerated** — still has `okf/`, snapshot files; `draft/index.md` carries `okf_version` frontmatter | WS-E | Low (re-run init) |
| **DD-9** | "Aether" naming → `codebase-memory-mcp` | WS-E (CLAUDE.md, 1 research doc) | Low |
| **DD-15** | CONTRIBUTING.md attributes `SKILL_ORDER` to wrong file (`build-integrations.sh` → `lib.sh`) | WS-E | Trivial |
| **DD-17** | Internal OKF research/design/plan docs status not flipped to "removed" | WS-E | Low |
| **DD-18** | "tree-sitter knowledge graph" branding → "codebase-memory-mcp" (likely-stale, verify) | WS-B | Low |

---

## 5. Per-workstream detail

### WS-A — Core website

**DD-1 (34→33):** `web/index.html` lines 7, 14, 21, 81, 265, 850, 1400; `web/what-is-draft/index.html` lines 7, 16, 26, 530.
**DD-2 (`/draft:index`):** `web/index.html` lines 884–886 (grid card "Monorepo federation"), 145 + 1456 (FAQ monorepo), 1313 (industry table row); `web/what-is-draft/index.html` line 690 (FAQ). Replace with `/draft:init` (scope-aware, run per module root).
**DD-3 (OKF):** `web/index.html` line 821 ("Open Knowledge Format emission/validation" in helpers card).
**DD-5 (specialists):** `web/what-is-draft/index.html` line 571 ("28 additional specialist" → 24), line 576 ("7 primary … 20+ specialist leaf" → "4 primary + 5 routers + 24 specialists").
**DD-7 (version):** `web/index.html` line 384 ("v2.8 · Built-in"), 787, 803 (bento tags "v2.8"), 515 (comparison footnote "Draft 2.8").
**Tools count:** `web/index.html` line 818 ("34 helpers"), 821 ("34 shell tools") → **32**.
**DD-14 (grid):** `web/index.html` ~875–1007 — `/draft:jira` duplicated (lines 944 & 948), missing `/draft:graph` + `/draft:upload`.
**DD-8 (install, verify):** FAQ JSON-LD lines 105/1421 + `what-is-draft` line 605 lead with `/plugin marketplace add` — decide whether to lead with `npx @drafthq/draft install claude-code` or keep marketplace as alt.
**Correct-as-history (no action):** `web/changelog/index.html` lines 245, 385, 404–409, 216–232 — legitimate per-version records. Line 286 (v2.6 committed-snapshot) optionally add "later removed in v3.0" note.

### WS-B — Book website (HTML; fix via sources + rebuild)

**DD-1 (34→33):** `chapters/00-what-is-draft.html:48`, `appendix-a-command-reference.html:5`, `20-multi-ide-support.html:73,111,185,188` (+ topic mirrors `what-is-draft/`, `command-reference/`, `multi-ide-support/`).
**DD-5 (25→24 specialists):** `00-what-is-draft.html:66`, `20-multi-ide-support.html:60` (+ mirrors).
**DD-2 (`/draft:index`):** **ch.18 monorepo-federation entirely about removed command** (lines 6, 49, 53, 59, 77, 100, 155, 174–184); `appendix-a:99–103` (table row) + line 55 (SVG); `00-what-is-draft.html:76, 95, 135`; `appendix-b-file-reference.html:340–376` ("Monorepo Root Files (from /draft:index)"); `21-philosophy-references.html:217`. Mirrors: `monorepo-federation/`, `command-reference/`, `file-reference/`, `philosophy-references/`.
**DD-6 (25-section→10):** `03-getting-started.html:203,256`, `02-context-driven-development.html:134` (+ mirrors).
**DD-12 (missing cmds):** `appendix-a` + `command-reference/` tables missing `graph`, `upload`, `integrations`.
**DD-18 (tree-sitter branding, verify):** `00-what-is-draft.html:68,72`, `03-getting-started.html:72` (+ mirrors).
**Caption conflict (verify):** "7 primary workflow parents" captions (`00-what-is-draft.html:167`, `appendix-a:70`) conflict with the 4+5+24 model.

### WS-C — Book sources (markdown — the fix target for WS-B)

**Counts:** `00_what_is_draft.md:11` (28→33), `:29` (22→24 specialists); `03_getting_started.md:15` (28→33); `20_multi_ide_support.md:13` (28→33), `:29` (25→33 skills), `:53` (25→33), `:25` (15,000+→~23,600), `:57` (22→62 core files); `22_command_reference.md:5,11` (28→33).
**DD-2:** `18_monorepo_federation.md` (whole chapter — lines 7,13,30,46,61,65,69,71); `21_philosophy_references.md:113`; `23_file_reference.md:23,25`.
**DD-13 (stubs):** `22_command_reference.md` is 12 lines with NO command table; `23_file_reference.md` `draft/ (Root)` section has empty file list. Both need full content reflecting the 33 skills + current `draft/` layout.
**DD-8 (hosts):** `20_multi_ide_support.md` missing codex + opencode; install shown as vague curl/marketplace, not `npx @drafthq/draft install <host>`. `00_what_is_draft.md:39` ("/plugin install").
**DD-6 (verify):** "25 sections" for architecture.md in `03_getting_started.md:88`, `02_context_driven_development.md:35,71`, `10_context_tiering.md:37` → 10-section.

### WS-D — Blog

**DD-4 + DD-3 — `local-graph-engine/index.html` (rewrite or retire):** lines 122–129 (old `draft/graph/` snapshot+okf tree), 128 (okf bundle), 130 ("checked into git"), 161–163 (§"Version-Controlled Context": "Commit them. Diff them."), 215 ("Then commit `draft/graph/`"), 104, 7/10/14/29 (meta "version-controlled"). Entire editorial thesis is the removed committed-graph model.
**DD-4 — `blast-radius-walkthrough/index.html`:** lines 125, 135, 262 — `/draft:implement` "loads `hotspots.jsonl`" (committed file). Reframe as live engine query.
**DD-4 — `mcp-tool-discovery/index.html:213`:** "`draft/graph/*.jsonl`, committed alongside the code" → live query.
**DD-4 — `decompose-payment-gateway/index.html:140`:** reads "`draft/graph/architecture.json`" → live query.
**DD-8 — `replaced-kiro-with-free-plugin/index.html:219–220`:** install snippet leads with `/plugin marketplace add` only → add `npx @drafthq/draft install claude-code`.
**Dated-but-ok:** blog posts are dated narratives; decide per post whether to rewrite (local-graph-engine — recommended) vs add a dated correction note (others). `web/blog/index.html` listing is clean except the local-graph-engine card excerpt (line 120), which updates when the post is fixed.

### WS-E — Root + internal docs + dogfood

**DD-2 — README.md:132:** remove stale `| /draft:index | Aggregate monorepo service contexts |` table row (then table = 32 `/draft:X` matching the "32 more commands" heading).
**DD-10 — CLAUDE.md:** line 9 ("native Aether binaries" + "34 shell helpers"); line 71 ("34"→32); line 16 ("44 test suites"→42); lines 27–30 (deleted Node `graph/` engine CLI block → `codebase-memory-mcp cli` / `graph-*.sh` wrappers); line 55 ("38 core files"→62); line 69 ("20 templates"→26); line 70 (stale `bin/<arch>/` description: "from Aether", non-existent `graph`/`graph-clang` binaries, wrong output-artifacts claim, "legacy fallback" that `bin/README.md` denies).
**DD-9 — Aether naming:** CLAUDE.md (above); `docs/internal/research/proposed-graph-backed-architecture-template.md:4`. (`bin/README.md` uses "Aether" only as historical contrast — OK.)
**DD-15 — CONTRIBUTING.md:87:** `SKILL_ORDER` lives in `scripts/lib.sh`, not `scripts/build-integrations.sh`.
**DD-11 — Dogfood `draft/` not regenerated:** `draft/graph/` still has `architecture.json`, `hotspots.jsonl`, `module-deps.mermaid`, `proto-map.mermaid`, and `okf/` (15 files); `draft/index.md` carries `okf_version: "0.1"` + OKF bundle framing. Fix: re-run `/draft:init` (or `graph-snapshot.sh`) which prunes them, and regenerate `draft/index.md` as a plain docs index.
**DD-17 — Internal OKF docs (lower priority):** `docs/internal/README.md:48` (status "Implemented" → "Implemented, then Removed"); `docs/internal/research/okf-open-knowledge-format-and-draft.md:5,11` (status block + `/draft:index` mention); `docs/internal/design/init-graph-simplification.md:32` (committed-snapshot table); `docs/internal/plans/graph-engine-replacement.md:91` + `COMMAND_REDUCTION_PLAN.md:103,266,577` (`/draft:index` references in plans).

---

## 6. Source-document map (fix at source, not generated output)

| Generated / downstream | Generated FROM | Rebuild command |
|------------------------|----------------|-----------------|
| `web/book/chapters/*.html` + `web/book/<topic>/index.html` | `book/notebook-sources/*.md` | `scripts/build-book.sh` |
| `integrations/copilot/.github/copilot-instructions.md`, `integrations/agents/AGENTS.md` | `skills/*/SKILL.md` + `core/*` | `scripts/build-integrations.sh` (or `make build`) |
| `draft/graph/schema.yaml` + pruned snapshot | live `codebase-memory-mcp` engine | `/draft:init` / `scripts/tools/graph-snapshot.sh` |

Notebook→chapter→topic mapping for the high-impact files: `18_monorepo_federation.md`→`chapters/18-*.html`→`monorepo-federation/`; `22_command_reference.md`→`appendix-a-*.html`→`command-reference/`; `23_file_reference.md`→`appendix-b-*.html`→`file-reference/`; `20_multi_ide_support.md`→`chapters/20-*.html`→`multi-ide-support/`; `00_what_is_draft.md`→`chapters/00-*.html`→`what-is-draft/`.

Note: agents found the HTML chapters have **diverged** from the notebooks (notebooks say "28 commands", HTML says "34"). Reconcile both to **33** when fixing — do not assume a clean regenerate will fix the HTML if the source is also wrong.

---

## 7. Recommended fix sequence

1. **DD-2 + DD-3 + DD-4 (the breaking-change purge)** — book sources (ch.18, 21, 23), README:132, blog `local-graph-engine`, dogfood `draft/`, web grid/FAQ. Highest correctness value.
2. **DD-1 + DD-5 + DD-6 + DD-7 + DD-16 (mechanical count/version sweep)** — fast, low-risk `grep`-and-replace across book sources + web. Rebuild book + integrations after.
3. **DD-10 + DD-9 + DD-15 (dev-doc hygiene)** — CLAUDE.md, CONTRIBUTING.md.
4. **DD-11 (regen dogfood)** — re-run init/graph-snapshot; verify only `schema.yaml` remains.
5. **DD-13 + DD-12 (fill stubs)** — author the real command-reference + file-reference content.
6. **DD-17 (internal status flips)** — last; lowest user impact.
7. **Rebuild + verify:** `scripts/build-book.sh`, `make build`, `make test`; re-grep the canonical stale strings to confirm zero remaining.

---

## 8. Reconciliation log

- 2026-06-14 — Audit created from 5-agent parallel review. All counts independently re-verified against `scripts/lib.sh`, `Makefile`, `scripts/tools/`, `core/templates/`. No fixes applied yet.
