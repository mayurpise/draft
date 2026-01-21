# Draft - Context-Driven Development

Draft is a methodology for structured software development that ensures consistent, high-quality delivery through: **Context → Spec & Plan → Implement**.

## Philosophy

"Measure twice, code once." By treating context as a managed artifact alongside code, the repository becomes a single source of truth that drives every agent interaction with deep, persistent project awareness.

## Core Concepts

### Tracks
A **track** is a high-level unit of work (feature, bug fix, refactor). Each track contains:
- `spec.md` - Requirements and acceptance criteria
- `plan.md` - Phased task breakdown
- `metadata.json` - Status and timestamps

### Project Context Files
Located in `draft/`:
- `product.md` - Product vision, users, goals
- `product-guidelines.md` - Style, branding, UX standards
- `tech-stack.md` - Languages, frameworks, patterns
- `workflow.md` - TDD preferences, commit strategy
- `tracks.md` - Master list of all tracks

## Status Markers
- `[ ]` - Pending/New
- `[~]` - In Progress  
- `[x]` - Completed
- `[!]` - Blocked

## Intent Mapping

When user says... → Use command:
- "set up draft" / "initialize project" → `/draft:setup`
- "new feature" / "start a track" / "add feature X" → `/draft:new-track`
- "implement" / "start coding" / "work on the plan" → `/draft:implement`
- "what's the status" / "show progress" → `/draft:status`
- "undo" / "revert the last change" → `/draft:revert`

## File References

If a user mentions "the plan" after using Draft, they likely mean:
- `draft/tracks.md` (master list)
- `draft/tracks/<track_id>/plan.md` (specific track plan)
