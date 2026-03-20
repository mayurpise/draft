# Enterprise Engineering Practices: Draft Improvement Plan & Resource Inventory

**Date:** 2026-03-19
**Purpose:** Gap analysis of Draft's current skills against enterprise engineering practices from Google, Apple, Meta, Microsoft, Netflix, and Amazon. Prioritized improvement roadmap and citable resource inventory.

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Draft Current State vs Enterprise Standard](#draft-current-state-vs-enterprise-standard)
3. [Improvement Recommendations](#improvement-recommendations)
4. [Resource Inventory](#resource-inventory)
5. [Implementation Priorities](#implementation-priorities)

---

## Executive Summary

Draft currently covers the core development lifecycle well: specification, planning, implementation with TDD, code review, bug hunting, and pattern learning. However, benchmarking against practices from Google, Meta, Microsoft, Netflix, and Amazon reveals **10 cross-cutting gaps** that separate Draft from enterprise-grade tooling:

| Gap | Severity | Which Companies Address It |
|-----|----------|---------------------------|
| Dependency/supply chain security | Critical | Google (OSS-Fuzz), Meta (Infer), Microsoft (SDL) |
| Mutation testing for test quality | High | Google (30% of all diffs), Microsoft (Pex) |
| Formal contract/API drift detection | High | Amazon (lightweight formal methods), Google (large-scale changes) |
| Observability-first development | High | Netflix (Full Cycle Developers), Google (SRE) |
| Chaos/resilience engineering | High | Netflix (Chaos Monkey), Amazon (GameDay) |
| Threat modeling integration | Medium | Microsoft (STRIDE/SDL), Apple (Platform Security) |
| Performance regression testing | Medium | Google (TAP benchmarks), Netflix (canary analysis) |
| Database/migration safety | Medium | Amazon (ShardStore verification), Google (large-scale changes) |
| SLO/error budget awareness | Medium | Google (SRE), Netflix (Kayenta) |
| Property-based & characterization testing | Medium | Amazon (S3 ShardStore), Google (fuzzing) |

**Bottom line:** Draft's quality dimensions are broad (11 in bughunt, 3-stage review, ACID in deep-review) but lack depth in supply chain security, test quality measurement, and production resilience. The highest-leverage improvements are: (1) adding dependency security scanning guidance, (2) integrating mutation testing concepts, and (3) adding a chaos/resilience checklist to deep-review.

---

## Draft Current State vs Enterprise Standard

### 1. Bug Finding (`/draft:bughunt`)

#### What Draft Does Well
- 11-dimension analysis with verification protocol (code trace, context cross-ref, framework check, prevalence check, false-positive elimination)
- Only HIGH/CONFIRMED confidence bugs reported (matches Google's <10% false-positive principle)
- Native regression test generation across 6+ language ecosystems
- Coverage status taxonomy (COVERED/PARTIAL/WRONG_ASSERTION/NO_COVERAGE/N/A)
- Draft context integration for architectural bug detection

#### What Enterprise Leaders Do Differently

**Google — Static Analysis at Scale**
- Tricorder analyzes 50,000+ code review changes/day across 30+ languages
- Error Prone: 500+ Java bug patterns as a compiler plugin with suggested fixes
- Key principle: "Analysis integrated into code review workflow, not a separate gate" (SWE Book Ch. 20)
- **Zero false-positive tolerance** at compile-time; up to 10% allowed at review-time

**Meta — Compositional Analysis**
- Infer uses separation logic and bi-abduction for compositional static analysis (finds null pointers, memory leaks, race conditions)
- Sapienz: search-based automated test generation for Android — 75% of reports actionable
- SapFix: automatically generates fixes for bugs found by Sapienz — end-to-end find-and-fix
- **Draft gap:** No automated fix generation; bughunt finds bugs and writes tests but doesn't propose code fixes

**Google — Fuzzing**
- OSS-Fuzz: 13,000+ vulnerabilities and 50,000+ bugs found across 1,000 projects
- ClusterFuzz: distributed execution, automatic bug triage, bisection, deduplication
- Combines libFuzzer, AFL++, Honggfuzz with sanitizers (ASan, MSan, UBSan)
- **Draft gap:** No fuzzing guidance; bughunt relies on pattern matching, not dynamic exploration of input space

**Amazon — Formal Methods**
- ShardStore (S3): specs embedded in Rust code, property-based testing + coverage-guided fuzzing + failure injection
- s2n TLS: continuous formal verification re-verified on every code change
- **Draft gap:** No formal specification or property-based testing integration

#### Recommended Improvements for Bughunt

| Priority | Improvement | Enterprise Reference |
|----------|------------|---------------------|
| P0 | Add **Dimension 12: Dependency Security** — check for known CVEs in dependencies, unpinned versions, deprecated packages | Google OSS-Fuzz, Microsoft SDL |
| P0 | Add **taint tracking guidance** — trace user input → dangerous sinks (SQL, shell, eval, innerHTML) end-to-end | Meta Infer, OWASP |
| P1 | Add **property-based testing signals** — when pure functions are found, suggest property-based tests alongside example tests | Amazon ShardStore, QuickCheck |
| P1 | Add **algorithmic complexity checks** — flag O(n^2) loops, regex catastrophic backtracking, unbounded recursion | Google Error Prone patterns |
| P2 | Add **fix suggestion generation** — for each confirmed bug, propose a minimal code fix (not just a test) | Meta SapFix |
| P2 | Add **secrets entropy scanning** — Shannon entropy analysis for detecting API keys in non-obvious variables | GitHub secret scanning, TruffleHog |

---

### 2. Test Generation & Coverage (`/draft:implement`, `/draft:coverage`)

#### What Draft Does Well
- TDD cycle enforcement: RED → GREEN → REFACTOR with mandatory test execution
- Multi-language test framework detection and native test generation
- Coverage gap classification: Testable / Defensive / Infrastructure
- 95% coverage target with delta comparison on re-run
- Developer approval checkpoint before recording coverage decisions

#### What Enterprise Leaders Do Differently

**Google — Mutation Testing at Scale**
- Used by 6,000 engineers, affects 14,000+ code authors, processes ~30% of all diffs
- Surfaced in code review (Critique) — not a separate gate
- Key insight: "Surfacing mutation results in code review actually changes developer behavior and improves test quality" (Petrovic et al., 2021)
- **Draft gap:** Tests are validated for syntax but never for strength. 95% line coverage can still have weak tests.

**Google — Test Philosophy**
- Test sizes (small/medium/large) defined by resource constraints, not scope
- "Prefer real implementations over mocks. Fakes > stubs > mocks" (SWE Book Ch. 13)
- "Test behavior, not implementation" — tests coupled to implementation break on refactoring
- "DAMP > DRY for tests" — clarity over deduplication in test code
- **Draft gap:** TDD cycle writes tests but no guidance on test quality beyond coverage percentage

**Microsoft — Automated Test Generation**
- IntelliTest: generates minimal test input sets that cover all reachable code via symbolic execution
- Pex/SAGE: whitebox fuzzing using symbolic execution + constraint solving — found MS07-017 vulnerability
- **Draft gap:** No symbolic execution or constraint-based test generation guidance

**Meta — Predictive Test Selection**
- ML-based selection of which tests to run for a given diff — avoids running full test suite on every change
- **Draft gap:** No test prioritization guidance for large codebases

#### Recommended Improvements for Testing

| Priority | Improvement | Enterprise Reference |
|----------|------------|---------------------|
| P0 | Add **mutation testing awareness** to coverage skill — after measuring coverage, prompt to consider mutation testing tools (PIT/Stryker/mutmut) to measure test strength | Google mutation testing program |
| P0 | Add **test quality checklist** to implement skill — no shared mutable fixtures, assertion density >1 per test, no logic in tests, DAMP over DRY | Google Testing Blog, SWE Book Ch. 12 |
| P1 | Add **branch/condition coverage** option — line coverage is insufficient for complex conditionals | ISTQB standards, MC/DC |
| P1 | Add **characterization testing guidance** for brownfield code — golden master / approval testing before refactoring | Michael Feathers, "Working Effectively with Legacy Code" |
| P1 | Add **property-based testing prompts** — for pure/mathematical functions, generate QuickCheck/Hypothesis/fast-check style tests | Amazon ShardStore, Haskell community |
| P2 | Add **contract testing guidance** — for service boundaries, generate consumer-driven contract tests (Pact, Spring Cloud Contract) | ThoughtWorks tech radar |
| P2 | Add **test pyramid enforcement** — flag when E2E tests outnumber integration tests, or integration outnumber unit tests | Google "Just Say No to More E2E Tests" |

---

### 3. Code Review (`/draft:review`, `core/agents/reviewer.md`)

#### What Draft Does Well
- Three-stage pipeline: Automated Validation → Spec Compliance → Code Quality
- Hard gate logic (fail-fast per stage)
- Adversarial pass when Stage 3 finds zero issues
- Scope flexibility (track/project/files/commits)
- Finding deduplication with severity-ordered merging

#### What Enterprise Leaders Do Differently

**Google — Lightweight and Fast**
- Median review turnaround < 4 hours, median change size < 100 lines
- "Approve if it improves overall code health, even if not perfect" (Google Eng Practices Guide)
- Three types of approval: LGTM (correctness), Approval (ownership), Readability (style)
- Analysis results, coverage, and test status integrated into review UI (Critique)
- **Draft gap:** No readability/style enforcement layer; no analysis tool integration

**Google — Code Health Culture**
- "Code Health" is an official recognized group — bottom-up culture, not mandates
- "Testing on the Toilet" — 200+ one-page best-practice flyers
- **Draft gap:** `/draft:learn` discovers patterns but doesn't generate one-pagers or team education materials

**Meta — Diff-Based Analysis**
- Infer runs on every diff in CI — results appear as inline comments in Phabricator
- Predictive test selection determines which tests to run for each diff
- **Draft gap:** Review skill doesn't suggest which static analysis tools to integrate based on tech stack

**Microsoft — Threat Modeling**
- STRIDE threat model applied to every new feature
- SDL integrates security into every development phase
- **Draft gap:** No threat modeling integration; new endpoints/APIs not checked against security models

#### Recommended Improvements for Review

| Priority | Improvement | Enterprise Reference |
|----------|------------|---------------------|
| P0 | Add **context-specific review focus** — crypto changes trigger crypto checks, DB migrations trigger schema checks, API changes trigger breaking-change detection | Google readability reviews |
| P0 | Add **SAST tool integration prompts** — based on tech-stack.md, suggest appropriate tools (Semgrep, CodeQL, Bandit, ESLint security) and check if they're configured | Meta Infer integration |
| P1 | Add **breaking change detection** for public APIs — exported signature changes flagged | Google large-scale changes |
| P1 | Add **threat model integration** — new endpoints/mutations checked against STRIDE categories | Microsoft SDL |
| P2 | Add **diff complexity metrics** — cyclomatic complexity, function length, cognitive complexity measured per-change | Google Critique |
| P2 | Enrich **adversarial pass** with `.ai-context.md` invariants and `guardrails.md` anti-patterns (currently 5 hardcoded questions) | Google Code Health |

---

### 4. Deep Review & Production Readiness (`/draft:deep-review`)

#### What Draft Does Well
- Module-level exhaustive audit (reads full module, not just diff)
- ACID compliance framework (Atomicity, Consistency, Isolation, Durability)
- Lifecycle tracing: init → process → persist → cleanup
- Review history rotation across modules
- Spec generation for fixes (not direct mutation)

#### What Enterprise Leaders Do Differently

**Netflix — Chaos Engineering**
- Chaos Monkey randomly terminates production instances
- Simian Army: Latency Monkey, Conformity Monkey, Doctor Monkey, Janitor Monkey
- Full Cycle Developers: teams own design, develop, test, deploy, operate, support
- Kayenta: automated canary analysis, statistical comparison of canary vs baseline
- **Draft gap:** No chaos engineering checklist; no questions about dependency failure, timeout, disk fill scenarios

**Google — SRE & Incident Management**
- SLO-based reliability targets drive engineering decisions
- Blameless postmortems as standard practice
- Error budgets determine when to invest in reliability vs features
- **Draft gap:** Deep-review has no SLO/SLA analysis dimension

**Amazon — Automated Reasoning**
- Lightweight formal methods embedded in code (not separate TLA+ specs)
- Property-based testing + coverage-guided fuzzing + failure injection
- AR replaced IAM authorization engine with proved-correct equivalent — 50% faster
- **Draft gap:** No formal verification or property-based testing integration

#### Recommended Improvements for Deep Review

| Priority | Improvement | Enterprise Reference |
|----------|------------|---------------------|
| P0 | Add **Phase 5: Resilience Assessment** — chaos engineering checklist: what happens when deps fail, timeouts fire, disk fills, clock skews, network partitions | Netflix Chaos Engineering, Amazon GameDay |
| P0 | Add **SLO/SLA analysis** — module error rates, latency profiles, availability vs defined targets; error budget burn assessment | Google SRE |
| P1 | Add **observability depth check** — structured log fields, log level correctness, PII leakage in logs, tracing span correctness, metric cardinality | Netflix Full Cycle Developers |
| P1 | Add **capacity/load modeling** — analysis at 10x/100x current traffic; identify bottlenecks before they trigger incidents | Netflix, Amazon |
| P1 | Extend **ACID phase** for non-SQL patterns — event-sourced, CQRS, Saga patterns have different consistency guarantees | Amazon distributed systems |
| P2 | Add **API contract drift detection** — compare code interfaces against OpenAPI/protobuf/GraphQL schema definitions | Amazon, Google |
| P2 | Add **database schema analysis** — missing indexes, wide table scans, schema without constraints, migration safety | Google large-scale changes |

---

### 5. Root Cause Analysis (`core/agents/rca.md`)

#### What Draft Does Well
- Blast radius scoping before investigation
- Differential analysis (working vs. failing case comparison)
- 5 Whys causal chain with hypothesis log table
- Blameless RCA format matching SRE best practices
- Root cause classification: 8 categories
- Distributed systems section: correlation IDs, event ordering, partial failure

#### What Enterprise Leaders Do Differently

**Google — SRE Postmortem Culture**
- Standard template: impact, root cause, trigger, detection, resolution, action items, lessons learned
- "You can't fix people, but you can fix systems"
- Postmortems are learning opportunities, not punishment
- Trend analysis across incidents to target systemic improvements
- **Draft gap:** No detection lag analysis, no SLO impact quantification

**Meta — Automated RCA**
- Minesweeper: automated RCA that identifies bug causes from symptoms in minutes
- DrP: programmable RCA platform, 300+ teams, 50K analyses daily, reduces MTTR 20-80%
- LLM-based ranking for root cause identification — 42% accuracy at investigation creation
- **Draft gap:** RCA is manual and investigator-driven; no automated correlation or suggestions

#### Recommended Improvements for RCA

| Priority | Improvement | Enterprise Reference |
|----------|------------|---------------------|
| P1 | Add **detection lag analysis** — when did this break vs when was it detected? Gap reveals monitoring gaps | Google SRE Postmortem |
| P1 | Add **SLO impact quantification** — error budget burn, customer impact in SLO terms | Google SRE |
| P1 | Add **prevention taxonomy** — classify actions as detection improvement, process improvement, code improvement, or architecture improvement | Google SRE Workbook |
| P2 | Add **automated timeline construction** — integrate `git log` + deploy history to auto-populate commit/deploy timeline around incident | Meta Minesweeper |
| P2 | Add **cross-incident pattern detection** — reference previous RCAs to identify systemic themes | Meta DrP |

---

### 6. Pattern Learning (`/draft:learn`)

#### What Draft Does Well
- 7-dimension scan with confidence thresholding (3-5x = medium, >5x = high)
- Convention vs. anti-pattern distinction drives correct downstream behavior
- Promotion workflow with human approval
- Evidence decay tracking (last_verified date)

#### Recommended Improvements

| Priority | Improvement | Enterprise Reference |
|----------|------------|---------------------|
| P1 | Add **temporal pattern analysis** — detect patterns being phased out (high occurrence in old files, low in new) | Google large-scale changes |
| P1 | Add **cross-service pattern comparison** in monorepos — flag inconsistencies across services | Google monorepo practices |
| P2 | Add **external benchmark comparison** — compare learned patterns against language community standards (Go idioms, PEPs, Effective Java) | Google Abseil Tips, Effective Java |
| P2 | Add **pattern conflict detection** — alert when two learned patterns contradict each other | Google Code Health |

---

## Resource Inventory

### Tier 1: Essential References (link from Draft documentation/reports)

These are the highest-value resources that engineers using Draft should reference for confirming practices and deepening understanding.

#### Books & Comprehensive Guides

| Resource | URL | When to Reference |
|----------|-----|-------------------|
| Software Engineering at Google (full book, free) | https://abseil.io/resources/swe-book/html/toc.html | Testing philosophy, code review, static analysis, large-scale changes |
| Site Reliability Engineering (SRE Book, free) | https://sre.google/sre-book/table-of-contents/ | Incident response, postmortems, monitoring, SLOs |
| The Site Reliability Workbook (free) | https://sre.google/workbook/table-of-contents/ | Practical SRE implementation, case studies |
| Working Effectively with Legacy Code (Michael Feathers) | ISBN: 978-0131177055 | Brownfield testing strategies, seam identification, characterization tests |

#### Testing & Quality

| Resource | URL | When to Reference |
|----------|-----|-------------------|
| Google Engineering Practices Guide (Code Review) | https://google.github.io/eng-practices/review/ | Code review standards, reviewer guide, CL author guide |
| Google Testing Blog | https://testing.googleblog.com/ | Testing best practices, mutation testing, coverage |
| "Test Behavior, Not Implementation" | https://testing.googleblog.com/2013/08/testing-on-toilet-test-behavior-not.html | Test design principles |
| "Code Coverage Best Practices" | https://testing.googleblog.com/2020/08/code-coverage-best-practices.html | Coverage philosophy |
| "Just Say No to More End-to-End Tests" | https://testing.googleblog.com/2015/04/just-say-no-to-more-end-to-end-tests.html | Test pyramid enforcement |
| "Don't Put Logic in Tests" | https://testing.googleblog.com/2014/07/testing-on-toilet-dont-put-logic-in.html | Test simplicity |

#### Bug Finding & Static Analysis

| Resource | URL | When to Reference |
|----------|-----|-------------------|
| "Lessons from Building Static Analysis Tools at Google" | https://cacm.acm.org/research/lessons-from-building-static-analysis-tools-at-google/ | False-positive management, developer adoption |
| Error Prone Bug Patterns Catalog | https://errorprone.info/bugpatterns | Java bug pattern reference |
| Meta Infer | https://fbinfer.com/ | Static analysis for Java/C/C++/ObjC |
| Infer GitHub | https://github.com/facebook/infer | Separation logic, compositional analysis |
| Clang Static Analyzer | https://clang-analyzer.llvm.org/ | C/C++/ObjC static analysis |
| OSS-Fuzz | https://github.com/google/oss-fuzz | Fuzzing infrastructure reference |

#### Security

| Resource | URL | When to Reference |
|----------|-----|-------------------|
| Microsoft SDL | https://www.microsoft.com/en-us/securityengineering/sdl | Security development lifecycle |
| STRIDE Threat Modeling | https://www.microsoft.com/en-us/securityengineering/sdl/threatmodeling | Threat modeling methodology |
| Microsoft Threat Modeling Tool Docs | https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats | STRIDE threat categories and mitigations |
| Apple Platform Security Guide | https://support.apple.com/guide/security/welcome/web | Platform security architecture reference |
| OWASP Testing Guide | https://owasp.org/www-project-web-security-testing-guide/ | Web application security testing |

#### Incident Response & RCA

| Resource | URL | When to Reference |
|----------|-----|-------------------|
| SRE Book: Postmortem Culture | https://sre.google/sre-book/postmortem-culture/ | Blameless postmortem practices |
| SRE Workbook: Postmortem Analysis | https://sre.google/workbook/postmortem-analysis/ | Postmortem template and process |
| SRE Book: Example Postmortem | https://sre.google/sre-book/example-postmortem/ | Annotated postmortem template |
| SRE Book: Managing Incidents | https://sre.google/sre-book/managing-incidents/ | Incident management (IMAG, ICS) |
| Google Incident Management Guide | https://sre.google/resources/practices-and-processes/incident-management-guide/ | Public incident management guide |
| SRE Book: Effective Troubleshooting | https://sre.google/sre-book/effective-troubleshooting/ | Systematic troubleshooting methodology |

#### Resilience & Production Engineering

| Resource | URL | When to Reference |
|----------|-----|-------------------|
| Netflix Chaos Monkey | https://netflix.github.io/chaosmonkey/ | Chaos engineering reference |
| Kayenta (Automated Canary Analysis) | https://netflixtechblog.com/automated-canary-analysis-at-netflix-with-kayenta-3260bc7acc69 | Canary deployment analysis |
| Netflix Full Cycle Developers | https://netflixtechblog.com/full-cycle-developers-at-netflix-a08c31f83249 | Operate-what-you-build philosophy |
| CMU SEI: Netflix Chaos Engineering Case Study | https://www.sei.cmu.edu/blog/devops-case-study-netflix-and-the-chaos-monkey/ | Academic analysis of chaos engineering |

#### Formal Methods & Automated Reasoning

| Resource | URL | When to Reference |
|----------|-----|-------------------|
| "Systems Correctness Practices at AWS" (CACM) | https://cacm.acm.org/practice/systems-correctness-practices-at-amazon-web-services/ | TLA+, lightweight formal methods, property-based testing |
| ShardStore: Lightweight Formal Methods at S3 (SOSP 2021) | https://www.amazon.science/publications/using-lightweight-formal-methods-to-validate-a-key-value-storage-node-in-amazon-s3 | Specs in code, property-based testing + fuzzing |
| Amazon Automated Reasoning Hub | https://www.amazon.science/research-areas/automated-reasoning | Central page for AR research |
| "Continuous Formal Verification of Amazon s2n" | https://link.springer.com/chapter/10.1007/978-3-319-96142-2_26 | Continuous verification in CI |

### Tier 2: Deep Dive References (for specific improvement initiatives)

#### Mutation Testing

| Resource | URL | When to Reference |
|----------|-----|-------------------|
| "State of Mutation Testing at Google" (ICSE 2018) | https://research.google.com/pubs/archive/46584.pdf | Scale and adoption metrics |
| "Practical Mutation Testing at Scale" (TSE 2021) | https://homes.cs.washington.edu/~rjust/publ/practical_mutation_testing_tse_2021.pdf | Scalability techniques |
| "Does Mutation Testing Improve Testing Practices?" | https://arxiv.org/pdf/2103.07189 | Evidence that mutation testing changes developer behavior |
| SE Radio 632: Goran Petrovic on Mutation Testing | https://se-radio.net/2024/09/se-radio-632-goran-petrovic-on-mutation-testing-at-google/ | Practical implementation details |

#### Code Coverage Research

| Resource | URL | When to Reference |
|----------|-----|-------------------|
| "Code Coverage at Google" (FSE 2019) | https://homes.cs.washington.edu/~rjust/publ/google_coverage_fse_2019.pdf | Changeset-level coverage in code review |
| "Measuring Coverage at Google" | https://testing.googleblog.com/2014/07/measuring-coverage-at-google.html | Coverage infrastructure design |

#### Automated Test Generation

| Resource | URL | When to Reference |
|----------|-----|-------------------|
| Meta Sapienz | https://engineering.fb.com/2018/05/02/developer-tools/sapienz-intelligent-automated-software-testing-at-scale/ | Search-based test generation |
| Meta SapFix | https://engineering.fb.com/2018/09/13/developer-tools/finding-and-fixing-software-bugs-automatically-with-sapfix-and-sapienz/ | Automated bug fix generation |
| Microsoft IntelliTest | https://learn.microsoft.com/en-us/visualstudio/test/intellitest-manual/?view=vs-2022 | Symbolic execution test generation |
| SAGE (Microsoft) | https://queue.acm.org/detail.cfm?id=2094081 | Whitebox fuzzing via symbolic execution |
| "Billions and Billions of Constraints" (ICSE 2013) | https://patricegodefroid.github.io/public_psfiles/icse2013.pdf | SAGE at production scale |

#### Automated RCA at Scale

| Resource | URL | When to Reference |
|----------|-----|-------------------|
| Meta Minesweeper | https://engineering.fb.com/2021/02/09/developer-tools/minesweeper/ | Automated root cause identification |
| Meta DrP | https://engineering.fb.com/2025/12/19/data-infrastructure/drp-metas-root-cause-analysis-platform-at-scale/ | Programmable RCA platform at scale |
| Meta AI for Incident Response | https://engineering.fb.com/2024/06/24/data-infrastructure/leveraging-ai-for-efficient-incident-response/ | LLM-based RCA ranking |

#### Code Review Research

| Resource | URL | When to Reference |
|----------|-----|-------------------|
| "Modern Code Review at Google" (ICSE 2018) | https://sback.it/publications/icse2018seip.pdf | Empirical study of review practices |
| Google Code Review Guide (GitHub) | https://github.com/google/eng-practices | Open-source review standards |
| "Tricorder" (ICSE 2015) | https://research.google.com/pubs/archive/43322.pdf | Program analysis ecosystem design |
| SWE Book Ch. 19: Critique Tool | https://abseil.io/resources/swe-book/html/ch19.html | Review tool UX design |

#### Apple Testing Resources

| Resource | URL | When to Reference |
|----------|-----|-------------------|
| XCTest Documentation | https://developer.apple.com/documentation/xctest | Apple's native test framework |
| "Write tests to fail" (WWDC 2020) | https://developer.apple.com/videos/play/wwdc2020/10091/ | Test design for diagnostic clarity |
| "Testing in Xcode" (WWDC 2019) | https://developer.apple.com/videos/play/wwdc2019/413/ | Test Plans and configurations |

#### AWS Operational Excellence

| Resource | URL | When to Reference |
|----------|-----|-------------------|
| AWS Well-Architected: Code Review Guidance | https://docs.aws.amazon.com/wellarchitected/latest/devops-guidance/dl.cr.2-perform-peer-review-for-code-changes.html | Peer review best practices |
| "How AR helps S3 innovate at scale" | https://aws.amazon.com/blogs/storage/how-automated-reasoning-helps-us-innovate-at-s3-scale/ | AR enabling faster releases |
| "AR makes systems more efficient" | https://aws.amazon.com/blogs/security/an-unexpected-discovery-automated-reasoning-often-makes-systems-more-efficient-and-easier-to-maintain/ | AR for performance optimization |

### Tier 3: Tools Reference (for skill instructions to recommend)

| Tool | Language/Platform | Purpose | URL |
|------|------------------|---------|-----|
| Error Prone | Java | Compile-time bug detection | https://errorprone.info/ |
| Infer | Java/C/C++/ObjC | Static analysis (null, leaks, races) | https://fbinfer.com/ |
| Semgrep | Multi-language | Lightweight static analysis | https://semgrep.dev/ |
| CodeQL | Multi-language | Semantic code analysis | https://codeql.github.com/ |
| Bandit | Python | Security linter | https://bandit.readthedocs.io/ |
| ESLint Security | JavaScript/TS | Security rules plugin | https://github.com/eslint-community/eslint-plugin-security |
| PIT | Java | Mutation testing | https://pitest.org/ |
| Stryker | JS/TS/C#/Scala | Mutation testing | https://stryker-mutator.io/ |
| mutmut | Python | Mutation testing | https://github.com/boxed/mutmut |
| cargo-mutants | Rust | Mutation testing | https://github.com/sourcefrog/cargo-mutants |
| Hypothesis | Python | Property-based testing | https://hypothesis.readthedocs.io/ |
| fast-check | JavaScript/TS | Property-based testing | https://fast-check.dev/ |
| QuickCheck | Haskell/Erlang | Property-based testing | https://hackage.haskell.org/package/QuickCheck |
| Pact | Multi-language | Consumer-driven contract testing | https://pact.io/ |
| OSS-Fuzz | C/C++/Go/Rust/Java/Python | Continuous fuzzing | https://github.com/google/oss-fuzz |
| AFL++ | C/C++ | Coverage-guided fuzzing | https://aflplus.plus/ |
| TruffleHog | Any | Secrets detection | https://github.com/trufflesecurity/trufflehog |
| Gitleaks | Any | Git secrets scanning | https://github.com/gitleaks/gitleaks |
| Trivy | Containers/IaC | Vulnerability scanner | https://trivy.dev/ |
| Snyk | Multi-language | Dependency vulnerability scanning | https://snyk.io/ |
| OWASP Dependency-Check | Java/.NET | Known vulnerability detection | https://owasp.org/www-project-dependency-check/ |
| Approval Tests | Multi-language | Golden master / characterization testing | https://approvaltests.com/ |

---

## Implementation Priorities

### Phase 1: Critical Gaps (P0) — Immediate Impact

These gaps represent security and correctness risks that enterprise users would flag immediately.

**1.1 Add Dependency Security Dimension to Bughunt**
- New Dimension 12: Supply Chain Security
- Check for known CVEs in dependencies (reference Snyk, Trivy, OWASP Dependency-Check)
- Flag unpinned versions, deprecated packages, license conflicts
- Reference: Google OSS-Fuzz, Microsoft SDL

**1.2 Add Taint Tracking Guidance to Bughunt**
- Enhance Dimension 3 (Security) with end-to-end data flow tracing
- User input → dangerous sinks (SQL, shell exec, eval, innerHTML, file paths)
- Reference: Meta Infer, OWASP Top 10

**1.3 Add Mutation Testing Awareness to Coverage**
- After measuring coverage, suggest mutation testing tools based on tech-stack
- Include tool recommendations by language (PIT, Stryker, mutmut, cargo-mutants)
- Reference: Google mutation testing program (30% of all diffs)

**1.4 Add Test Quality Checklist to Implement**
- Enforce during TDD cycle: no shared mutable fixtures, assertion density >1, no logic in tests, DAMP > DRY
- Reference: SWE Book Ch. 12, Google Testing Blog

**1.5 Add Context-Specific Review Focus to Review**
- Crypto changes → crypto checks; DB migrations → schema checks; API changes → breaking-change detection
- Reference: Google readability reviews

**1.6 Add SAST Tool Integration Prompts to Review**
- Based on tech-stack.md, recommend appropriate SAST tools and check if configured
- Reference: Meta Infer CI integration, Semgrep, CodeQL

### Phase 2: High-Value Improvements (P1) — Competitive Differentiation

**2.1 Add Resilience Assessment Phase to Deep Review**
- Chaos engineering checklist: dependency failure, timeout, disk fill, network partition
- Reference: Netflix Chaos Monkey, Amazon GameDay

**2.2 Add SLO/SLA Analysis to Deep Review**
- Error budget burn, latency profiles, availability vs targets
- Reference: Google SRE

**2.3 Add Observability Depth Check to Deep Review**
- Structured logs, log level correctness, PII in logs, tracing spans, metric cardinality
- Reference: Netflix Full Cycle Developers

**2.4 Add Property-Based Testing to Implement/Bughunt**
- Identify pure functions and suggest property-based tests
- Include tool recommendations by language (Hypothesis, fast-check, QuickCheck)
- Reference: Amazon ShardStore, Google fuzzing

**2.5 Add Characterization Testing Guidance**
- For brownfield refactoring: golden master / approval testing before changing code
- Reference: Michael Feathers, Approval Tests

**2.6 Add Branch/Condition Coverage Option**
- Beyond line coverage for safety-critical or complex conditional code
- Reference: ISTQB, MC/DC coverage criteria

**2.7 Add Temporal Pattern Analysis to Learn**
- Detect patterns being phased out (high in old files, low in new)
- Reference: Google large-scale changes

**2.8 Enhance RCA with Detection Lag Analysis and Prevention Taxonomy**
- When did it break vs when detected? Classify prevention actions.
- Reference: Google SRE Postmortem, SRE Workbook

### Phase 3: Advanced Capabilities (P2) — Enterprise Maturity

**3.1 Add Fix Suggestion Generation to Bughunt**
- For each confirmed bug, propose minimal code fix
- Reference: Meta SapFix

**3.2 Add API Contract Drift Detection**
- Compare code interfaces against OpenAPI/protobuf/GraphQL schemas
- Reference: Amazon, Google large-scale changes

**3.3 Add Database Schema Analysis**
- Missing indexes, wide table scans, migration safety
- Reference: Google large-scale changes

**3.4 Extend ACID Phase for Non-SQL Patterns**
- Event-sourced, CQRS, Saga pattern consistency guarantees
- Reference: Amazon distributed systems

**3.5 Add Cross-Incident Pattern Detection to RCA**
- Reference previous RCAs to identify systemic themes
- Reference: Meta DrP

**3.6 Add Performance Regression Testing Guidance**
- Benchmark test generation for latency-sensitive code
- Reference: Google TAP, Netflix Kayenta

**3.7 Add Internationalization/Localization Dimension**
- Hardcoded strings, locale-sensitive comparisons, RTL layout
- Currently absent from all skills

**3.8 Add Infrastructure-as-Code Review**
- Terraform, Helm, Kubernetes manifests
- Currently absent from all skills

---

## Appendix: Company Practice Summary Matrix

| Practice | Google | Meta | Microsoft | Netflix | Amazon | Draft Today | Draft Target |
|----------|--------|------|-----------|---------|--------|-------------|-------------|
| Static analysis in CI | Tricorder, Error Prone | Infer | SDL tools | - | - | Manual pattern matching | SAST tool integration prompts |
| Fuzzing | OSS-Fuzz, ClusterFuzz | - | SAGE | - | ShardStore | Not covered | Fuzzing guidance by language |
| Mutation testing | 30% of diffs | - | Pex | - | - | Not covered | Coverage skill integration |
| Property-based testing | - | - | IntelliTest | - | ShardStore | Not covered | Implement/bughunt prompts |
| Code review tooling | Critique + readability | Phabricator | Azure DevOps | - | Internal | Three-stage review | Context-specific focus |
| Chaos engineering | DiRT | - | - | Chaos Monkey | GameDay | Not covered | Deep-review resilience phase |
| SLO/error budgets | SRE | - | - | Kayenta | - | Not covered | Deep-review SLO analysis |
| Blameless postmortems | SRE Book | Minesweeper, DrP | - | - | - | RCA agent | Enhanced with detection lag |
| Formal methods | - | - | - | - | TLA+, AR | Not covered | Property-based testing |
| Automated fix generation | - | SapFix | - | - | - | Not covered | Bughunt P2 |
| Dependency security | OSS-Fuzz | - | SDL | - | - | Not covered | Bughunt Dimension 12 |
| Observability enforcement | SRE | - | - | Full Cycle Dev | - | Deep-review only | Implementation-time |
| Threat modeling | - | - | STRIDE/SDL | - | - | Not covered | Review integration |
| Test pyramid | SWE Book | Predictive selection | - | - | - | Not enforced | Review/coverage |
| Characterization tests | - | - | - | - | - | Not covered | Brownfield guidance |

---

## Appendix B: Brownfield/Legacy Code Strategies

These methodologies are directly relevant to Draft's target audience — engineers working on existing codebases.

### Characterization Testing (Michael Feathers)
**Source:** "Working Effectively with Legacy Code" (ISBN 978-0131177052)
**Summary:** https://understandlegacycode.com/blog/key-points-of-working-effectively-with-legacy-code/

A characterization test captures **actual behavior** (not spec behavior) of existing code. When spec differs from observed behavior, use observed behavior — that's what users depend on. This is the safety net before refactoring brownfield code.

**Draft integration point:** `/draft:implement` should prompt for characterization tests before refactoring existing code. `/draft:bughunt` should distinguish "bug vs. intentional quirk" using characterization tests as baseline.

### Seam Identification
**Source:** Michael Feathers, "Working Effectively with Legacy Code"

A "seam" is a place where you can alter program behavior without editing the code at that place. Three types:
- **Object Seams** — interfaces + dependency injection → swap implementations for testing
- **Preprocessing Seams** — macros/conditional compilation → swap at build time
- **Link Seams** — classpath/module resolution → swap at link/import time

**The Legacy Code Dilemma:** Need tests to change code safely; need to change code to add tests. Seams break this cycle.

**Draft integration point:** `/draft:implement` should identify seams when working with untested brownfield code before the TDD cycle begins.

### Golden Master / Approval Testing
**References:**
- https://understandlegacycode.com/approval-tests/
- https://www.codurance.com/publications/2012/11/11/testing-legacy-code-with-golden-master
- https://blog.thecodewhisperer.com/permalink/surviving-legacy-code-with-golden-master-and-sampling
- https://approvaltests.com/

Create fixed-seed random inputs → capture all outputs as "Golden Master" → refactor freely (any output change = regression). Start with Golden Master for untested code, then write proper unit tests via TDD during refactoring. Approval tests can be removed once proper suite exists.

**Draft integration point:** `/draft:coverage` should suggest Golden Master approach when encountering modules with 0% coverage that need refactoring.

### Strangler Fig Pattern
**References:**
- Martin Fowler: https://martinfowler.com/bliki/StranglerFigApplication.html
- Azure: https://learn.microsoft.com/en-us/azure/architecture/patterns/strangler-fig
- Shopify: https://shopify.engineering/refactoring-legacy-code-strangler-fig-pattern

Facade/proxy intercepts requests, routing to either legacy or new system. Replace in "thin slices" — small enough to manage, large enough for business value. Enables business continuity during migration.

**Draft integration point:** `/draft:decompose` should consider Strangler Fig when decomposing monolithic modules.

---

## Appendix C: Academic Test Generation Tools

These tools represent the state of the art in automated test generation and should inform Draft's testing guidance.

| Tool | Language | Approach | URL | Key Insight |
|------|----------|----------|-----|-------------|
| EvoSuite | Java | Genetic algorithms optimizing whole test suites toward coverage criteria | https://www.evosuite.org/ | Produces minimized JUnit tests with regression assertions |
| Randoop | Java | Feedback-directed random testing; sequences of method invocations | https://randoop.github.io/randoop/ | Detects broken equals/hashCode contracts automatically |
| Pynguin | Python | DynaMOSA/MIO/MOSA algorithms for Python unit tests | https://www.pynguin.eu/ | First automated test gen for Python; must run in isolated env |
| Diffblue Cover | Java | Reinforcement learning (not LLM) for autonomous test gen | https://www.diffblue.com/ | 20x productivity vs AI coding assistants; RL is more deterministic than LLM |
| KLEE | C/C++ (LLVM) | Symbolic VM exploring paths via constraint solvers | https://github.com/klee/klee | 90%+ line coverage on average |
| FlashFuzz | Python | LLM + libFuzzer hybrid | (2025 research) | Found 42 unknown bugs in PyTorch/TensorFlow |

---

## Appendix D: Industry Standards & Frameworks

| Standard | URL | Relevance to Draft |
|----------|-----|-------------------|
| **DORA Metrics** | https://dora.dev | Testing quality impacts all 4 metrics; Draft could track DORA indicators |
| **OWASP WSTG** | https://owasp.org/www-project-web-security-testing-guide/ | Bughunt security dimension should reference WSTG techniques |
| **ISO/IEC 25010** | https://iso25000.com/en/iso-25000-standards/iso-25010 | 8 quality characteristics; testability is sub-characteristic of maintainability |
| **ISTQB** | https://istqb.org/ | Standardized test vocabulary: equivalence partitioning, boundary values, decision tables |
| **IEEE 829** | https://ieeexplore.ieee.org/document/4578383 | Test documentation taxonomy (8 document types) |
| **The Fuzzing Book** | https://www.fuzzingbook.org/ | Comprehensive interactive textbook on automated testing and fuzzing |
| **TLA+** | https://lamport.azurewebsites.net/tla/formal-methods-amazon.pdf | AWS formal methods for concurrent/distributed system correctness |
