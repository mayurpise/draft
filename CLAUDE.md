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

## Maintaining This Plugin

This plugin supports multiple integrations (Claude Code, Cursor). When updating the methodology:

### Source of Truth
- `core/methodology.md` - Canonical methodology documentation
- `core/templates/` - Template files for project setup
- `core/agents/` - Agent behavior definitions

### Sync Process

When the user requests changes to the Draft methodology:

1. **Update `core/methodology.md`** first with the conceptual change
2. **Update Claude Code files** - Apply changes to relevant files in:
   - `commands/` - Update command behavior
   - `skills/draft/SKILL.md` - Update skill triggers/behavior
   - `CLAUDE.md` - Update if core concepts change
3. **Update Cursor integration** - Apply same changes to:
   - `integrations/cursor/.cursorrules` - Keep in sync with methodology

### Example

User: "Add a new status marker [?] for 'Needs Review'"

Action:
1. Add `[?] - Needs Review` to `core/methodology.md` Status Markers section
2. Add to `commands/implement.md` task scanning logic
3. Add to `CLAUDE.md` Status Markers section
4. Add to `integrations/cursor/.cursorrules` Status Markers section
