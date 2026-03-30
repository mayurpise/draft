---
project: "draft"
module: "root"
generated_by: "draft:evaluation"
generated_at: "2026-03-30T19:30:00Z"
---

# Draft Context Quality Benchmark Suite

Systematic benchmark for measuring Draft context accuracy, staleness, token efficiency, and self-improvement over time. Designed to evaluate the six supermemory-inspired enhancements against the baseline.

## Benchmark Philosophy

Each benchmark simulates **real-world codebase evolution** — the exact scenario where context degrades. We measure how well Draft's context tracks reality after code changes, not just how well it captures initial state.

---

## Benchmark 1: Staleness Detection (Contradiction Detection)

**Measures:** How many stale facts survive in `.ai-context.md` after known code changes.

### Setup

1. Select 5 open-source projects of varying size (small: <50 files, medium: 50-200, large: 200+)
2. For each project, run `/draft:init` to establish baseline context
3. Record baseline fact count, section content, and all generated files

### Test Protocol

For each project, apply 10 predefined code mutations (one at a time):

| Mutation Type | Example | What Should Change in Context |
|---|---|---|
| **Framework migration** | Replace Express with Fastify | API style, route patterns, middleware description |
| **Auth mechanism change** | Replace session cookies with JWT | Auth section, security invariants |
| **Database switch** | Replace PostgreSQL with MongoDB | DB references, query patterns, schema descriptions |
| **API style change** | Add WebSocket alongside REST | API type, data flow diagrams |
| **Dependency removal** | Remove Redis caching layer | Dependency graph, caching descriptions |
| **New module addition** | Add a background job processor | Component map, concurrency model |
| **File restructure** | Move from flat to domain-grouped dirs | File layout, import paths |
| **Config mechanism change** | Replace .env with Vault | Config section, security model |
| **Test framework switch** | Replace Jest with Vitest | Test commands, test patterns |
| **Entry point change** | Refactor from single to multi-binary | Entry point, process lifecycle |

### Measurement

After each mutation, run `/draft:init refresh` and measure:

| Metric | Formula | Target |
|---|---|---|
| **Staleness Rate** | `stale_facts / total_facts × 100` | <5% (baseline likely 15-30%) |
| **Contradiction Detection Rate** | `detected_contradictions / actual_contradictions × 100` | >90% |
| **False Contradiction Rate** | `false_contradictions / detected_contradictions × 100` | <10% |
| **Fact Evolution Accuracy** | `correct_updates / total_updates × 100` | >85% |

### Scoring: Baseline vs. Enhanced

| Scenario | Baseline (section-level refresh) | Enhanced (fact-level contradiction detection) |
|---|---|---|
| After 1 mutation | Measure stale facts | Measure stale facts |
| After 5 mutations (cumulative) | Measure stale facts | Measure stale facts |
| After 10 mutations (cumulative) | Measure stale facts | Measure stale facts |

**Expected result:** Baseline staleness compounds with each mutation (facts from early sections survive). Enhanced version catches contradictions at fact level, keeping staleness near-zero.

---

## Benchmark 2: Token Efficiency (Profile + Relevance Scoring)

**Measures:** How many tokens are loaded per task, and what percentage are actually relevant.

### Setup

1. Use the same 5 projects from Benchmark 1 (post-init, before mutations)
2. Define 20 standardized tasks across 4 categories:

| Category | Tasks (5 each) | Expected Context Needs |
|---|---|---|
| **Simple config** | Change env var, update dependency version, modify build script, add .gitignore entry, update README | Profile only (Tier 0) |
| **Single-file fix** | Fix a type error, handle null check, add input validation, fix off-by-one, add logging | Profile + relevant sections of Tier 1 |
| **Feature implementation** | Add new API endpoint, new UI component, new background job, new auth route, new test suite | Full Tier 0 + relevant Tier 1 + track context |
| **Architecture change** | Refactor module boundary, add new service, change data flow, add caching layer, split monolith | Full Tier 0 + Tier 1 + Tier 2 facts |

### Measurement

For each task, measure:

| Metric | Formula | How to Measure |
|---|---|---|
| **Tokens Loaded (Baseline)** | Count tokens in all files loaded by baseline context loading | Tokenize all loaded files |
| **Tokens Loaded (Enhanced)** | Count tokens in profile + relevant sections + relevant facts | Tokenize loaded subset |
| **Token Reduction %** | `(baseline - enhanced) / baseline × 100` | Compare |
| **Relevance Precision** | `relevant_tokens / total_loaded_tokens × 100` | Human judge: for each loaded section, was it needed? |
| **Relevance Recall** | `loaded_relevant_sections / all_relevant_sections × 100` | Human judge: were any needed sections missed? |

### Expected Results

| Task Category | Baseline Tokens | Enhanced Tokens | Expected Reduction |
|---|---|---|---|
| Simple config | 800-1600 (full .ai-context.md) | 100-200 (.ai-profile.md) | **75-90%** |
| Single-file fix | 800-1600 | 300-600 (profile + 2-3 sections) | **50-70%** |
| Feature implementation | 800-1600 | 500-1000 (profile + relevant sections) | **20-40%** |
| Architecture change | 800-1600 | 800-1600 (full context needed) | **0-10%** |

**Weighted average across typical task distribution (40% simple, 30% single-file, 20% feature, 10% architecture):** Expected **45-60% token reduction**.

---

## Benchmark 3: Context Accuracy Over Time (Self-Improvement)

**Measures:** Does context accuracy improve with repeated quality command runs?

### Setup

1. Select 3 projects with known coding patterns (both good and problematic)
2. Seed each project with:
   - 5 intentional conventions (consistent patterns across 5+ files)
   - 5 intentional anti-patterns (known bugs replicated in 3+ locations)
   - 3 declining patterns (old style in old files, new style in new files)

### Test Protocol

Run this cycle 5 times:

```
Cycle N:
  1. Run /draft:learn
  2. Run /draft:bughunt
  3. Run /draft:review (project-level)
  4. Measure accuracy metrics
```

### Measurement

After each cycle, measure:

| Metric | Formula | How to Measure |
|---|---|---|
| **Convention Discovery Rate** | `correctly_learned_conventions / total_seeded_conventions × 100` | Compare guardrails.md against seeded conventions |
| **Anti-Pattern Discovery Rate** | `correctly_learned_antipatterns / total_seeded_antipatterns × 100` | Compare guardrails.md against seeded anti-patterns |
| **False Positive Rate** | `false_positives / total_findings × 100` | Human review of bughunt/review findings |
| **Declining Pattern Detection** | `correctly_identified_declining / total_seeded_declining × 100` | Check if declining patterns flagged appropriately |
| **Temporal Accuracy** | `correct_established_at / total_learned × 100` | Compare git blame dates against `established_at` timestamps |

### Expected Results

| Cycle | Convention Discovery | Anti-Pattern Discovery | False Positive Rate |
|---|---|---|---|
| 1 | 40-60% | 30-50% | 20-30% |
| 2 | 60-80% | 50-70% | 15-20% |
| 3 | 80-90% | 70-85% | 10-15% |
| 4 | 85-95% | 80-90% | 5-10% |
| 5 | 90-95% | 85-95% | <5% |

**Key insight:** The baseline (without dual-layer timestamps) will plateau at cycle 2-3 because it can't distinguish declining patterns from active conventions. Enhanced version should continue improving through cycle 5.

---

## Benchmark 4: Fact Registry Precision (Atomic Facts)

**Measures:** How accurately does the fact registry represent the actual codebase?

### Setup

1. For each of the 5 projects, manually extract "ground truth" facts by having a human engineer read the codebase and write 50-100 factual statements
2. Run `/draft:init` to generate `facts.json`

### Measurement

| Metric | Formula | Target |
|---|---|---|
| **Fact Precision** | `correct_facts / total_extracted_facts × 100` | >90% (facts are true) |
| **Fact Recall** | `extracted_facts_matching_ground_truth / ground_truth_facts × 100` | >70% (most important facts captured) |
| **Category Coverage** | `categories_with_facts / 10 × 100` | >80% (at least 8/10 categories populated) |
| **Source Traceability** | `facts_with_valid_source_refs / total_facts × 100` | >95% (almost all facts point to real files) |
| **Relationship Accuracy** | `correct_relationships / total_relationships × 100` | >80% (edges are meaningful) |

### Post-Mutation Accuracy

After applying the 10 mutations from Benchmark 1:

| Metric | Before Refresh | After Refresh | Target Delta |
|---|---|---|---|
| Fact Precision | Measure | Measure | Should improve or stay same |
| Fact Recall | Measure | Measure | Should improve (new facts added) |
| Stale Fact Count | Measure | Measure | Should decrease to near-zero |

---

## Benchmark 5: Knowledge Graph Utility (Relationship Edges)

**Measures:** Do knowledge graph relationships provide actionable value?

### Test Protocol

For each project, ask 10 "what changed?" questions that require traversing the knowledge graph:

| Question Type | Example | Requires |
|---|---|---|
| **Evolution query** | "What changed about the auth system?" | Traversing `updates` edges from auth-related facts |
| **Impact query** | "What depends on the database layer?" | Traversing `extends` and `derives` edges |
| **History query** | "When did we switch from REST to tRPC?" | Reading `supersedes`/`superseded_by` chains with timestamps |
| **Consistency query** | "Are all API endpoints using the same auth middleware?" | Cross-referencing api-contract + security facts |
| **Drift query** | "What's different about the codebase since architecture.md was generated?" | Comparing current `facts.json` against initial snapshot |

### Measurement

| Metric | Without Graph | With Graph | Target |
|---|---|---|---|
| **Answer Accuracy** | Human rates 1-5 | Human rates 1-5 | +1.0 average improvement |
| **Answer Completeness** | % of relevant facts included | % of relevant facts included | +20% |
| **Time to Answer** | Token count for response | Token count for response | -30% (more direct answers) |

---

## Execution Plan

### Phase 1: Baseline Measurement (1-2 days)

1. Select 5 projects:
   - **Small**: A CLI tool (~30 files)
   - **Medium-small**: A REST API (~80 files)
   - **Medium**: A web app (~150 files)
   - **Medium-large**: A monorepo with 2-3 services (~300 files)
   - **Large**: A full-stack app (~500+ files)

2. Run `/draft:init` on each **without** the enhancements (checkout pre-enhancement commit)
3. Record all baseline metrics for Benchmarks 1-5

### Phase 2: Enhanced Measurement (1-2 days)

1. Run `/draft:init` on each **with** the enhancements (checkout post-enhancement commit)
2. Record all enhanced metrics for Benchmarks 1-5
3. Apply the 10 code mutations and measure refresh accuracy

### Phase 3: Longitudinal Test (1 week)

1. Pick 2 projects and simulate realistic development:
   - Day 1: `/draft:init`
   - Day 2: 5 code changes + `/draft:init refresh`
   - Day 3: `/draft:learn` + `/draft:bughunt`
   - Day 4: 5 more code changes + `/draft:init refresh`
   - Day 5: `/draft:review` + `/draft:learn`
   - Day 6: 3 code changes + `/draft:init refresh`
   - Day 7: Full measurement of all metrics

2. Compare Day 1 accuracy vs. Day 7 accuracy (should improve)

### Phase 4: Analysis & Reporting

Produce a final report with:
- Per-benchmark results table (baseline vs. enhanced)
- Aggregate improvement percentages
- Identified weaknesses or regressions
- Recommendations for further improvement

---

## Aggregate Scoring

Final score combines all benchmarks with weights reflecting real-world impact:

| Benchmark | Weight | Rationale |
|---|---|---|
| B1: Staleness Detection | 30% | #1 cause of bad AI-generated code |
| B2: Token Efficiency | 20% | Directly impacts cost and speed |
| B3: Self-Improvement | 25% | Compounding value over time |
| B4: Fact Registry Precision | 15% | Foundation for all other improvements |
| B5: Knowledge Graph Utility | 10% | Long-term value, hard to measure now |

**Overall Score** = Σ (benchmark_score × weight)

Target: **>30% weighted improvement** over baseline across all 5 projects.

---

## Automation Notes

Benchmarks 1, 2, and 4 can be partially automated:
- Token counting: use `tiktoken` or similar tokenizer
- Staleness detection: compare `facts.json` before/after mutations programmatically
- Source traceability: verify file paths exist with `stat`

Benchmarks 3 and 5 require human judgment for:
- False positive classification
- Answer quality rating
- Convention/anti-pattern correctness verification

Consider building a lightweight harness that runs mutations, invokes Draft commands, and collects metrics automatically.
