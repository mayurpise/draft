# Product Guidelines

## Writing Style
- Tone: Direct, professional, technical
- Voice: Second person imperative ("Run this command", "Create a track")
- No emojis in generated artifacts unless user requests them
- Lead with conclusions and actionable steps

## Documentation Standards
- Skill files use YAML frontmatter + markdown body
- Templates are complete, copy-ready markdown
- All user-facing text is concise and scannable
- Status markers are consistent: `[ ]` `[~]` `[x]` `[!]`

## UX Principles
- Convention over configuration — sensible defaults, optional customization
- Human review before AI execution — specs/plans are checkpoints, not rubber stamps
- Filesystem as UI — all state is readable markdown/JSON, no hidden databases
- Incremental progress — phased implementation with clear boundaries
- Safe by default — revert operations are git-aware and non-destructive

## CLI Interaction Patterns
- Commands are discoverable via `/draft` overview
- Natural language intent mapping to commands
- Progress feedback through status markers in plan.md
- Errors surface as blocked `[!]` markers with explanations
