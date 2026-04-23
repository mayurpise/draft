Hey @mayurpise 👋

I ran your skills through `tessl skill review` at work and found some targeted improvements. Here's the full before/after:

![score_card](../score_card.png)

| Skill | Before | After | Change |
|-------|--------|-------|--------|
| draft | 55% | 90% | +35% |
| bughunt | 54% | 81% | +27% |
| review | 54% | 81% | +27% |
| implement | 58% | 84% | +26% |
| debug | 81% | 94% | +13% |

<details>
<summary>Changes made</summary>

**Description improvements (biggest impact across all 5 skills):**
- **draft**: Rewrote from vague second-person overview to specific third-person description listing concrete actions (lists CLI commands, explains CDD workflow, recommends next step) with explicit "Use when..." clause and natural trigger terms
- **review**: Expanded from terse label to full description covering scope (track-level vs project-level), three-stage pipeline, and optional bughunt integration with "Use when..." clause
- **implement**: Added TDD workflow specifics (red-green-refactor), one-task-at-a-time commit model, phase boundary reviews, and natural trigger terms like "start coding", "continue a plan"
- **debug**: Enriched with natural error-related trigger terms ("error", "crash", "exception", "stack trace", "not working") that users actually say when they need debugging help
- **bughunt**: Added "14-dimension" specificity, listed concrete outputs (code evidence, data flow traces, suggested fixes), and added natural trigger terms ("find bugs", "code audit", "scan for vulnerabilities")

**Content improvements:**
- **draft**: Removed tangential "Relationship to Built-in Bug Hunt Agents" paragraph (saves tokens, not useful for skill execution)
- **review**: Removed SAST tool recommendation table (Claude already knows language-specific security tools) and consolidated verbose error handling templates into a compact table (~70 lines saved)
- **implement**: Condensed Production Robustness Patterns from ~70-line trigger/pattern tables into compact bulleted summaries (~55 lines saved); condensed characterization testing, property-based testing checkpoint, observability prompts, and contract testing sections (~30 lines saved)

I kept this PR focused on the 5 skills with the biggest improvements to keep the diff reviewable. Happy to follow up with the rest in a separate PR if you'd like.

</details>

Honest disclosure — I work at @tesslio where we build tooling around skills like these. Not a pitch - just saw room for improvement and wanted to contribute.

Want to self-improve your skills? Just point your agent (Claude Code, Codex, etc.) at [this Tessl guide](https://docs.tessl.io/evaluate/optimize-a-skill-using-best-practices) and ask it to optimize your skill. Ping me - [@yogesh-tessl](https://github.com/yogesh-tessl) - if you hit any snags.

Thanks in advance 🙏
