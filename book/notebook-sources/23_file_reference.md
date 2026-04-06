# Chapter 23: Appendix B: File Reference

Appendix

Every file Draft generates, organized by directory. For each file: name, purpose, typical size, audience, and lifecycle.

## draft/ (Root)

## draft/.state/

Internal state files for incremental refresh, signal classification, and cross-session continuity. Not intended for direct editing.

## draft/tracks/<track-name>/

Each track (feature, fix, or refactor) gets its own directory with these files:

## Optional Track Files

These files are created by specific commands when run against a track:

## draft/adrs/

## Monorepo Root Files (from /draft:index)

Generated at the monorepo root level when/draft:indexaggregates service contexts:

architecture.mdis the source of truth..ai-context.mdis derived from it (token-optimized for AI)..ai-profile.mdis derived from.ai-context.md(ultra-compact, always loaded). Edits flow downward: updatearchitecture.md, then the derived files are regenerated automatically via the Condensation Subroutine.

