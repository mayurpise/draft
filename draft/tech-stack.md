# Tech Stack

## Languages
- Primary: Markdown (skill definitions, templates, methodology docs)
- Secondary: YAML (skill frontmatter, configuration)
- Secondary: JSON (plugin manifest, metadata)
- Build: Bash (cursorrules generation script)

## Frameworks
- Claude Code Plugin SDK: Skill-based plugin architecture
- Cursor Integration: Generated .cursorrules file
- GitHub Copilot Integration: Generated copilot-instructions.md file

## Database
- Filesystem: Markdown and JSON files in `draft/` directory
- Git: Version history and rollback support

## Testing
- Unit: Strict TDD (RED → GREEN → REFACTOR)
- Integration: End-to-end skill execution verification
- Verification: Fresh test/build/lint evidence before completion

## Build & Deploy
- Build: `./scripts/build-integrations.sh` (generates Cursor + Copilot integrations from skills)
- CI/CD: N/A (plugin distributed via git clone / marketplace)
- Deploy: GitHub repository + Claude Code plugin marketplace

## Code Patterns
- Architecture: Skill-based plugin (each command = one SKILL.md)
- Source of Truth: methodology.md → skills → .cursorrules / copilot-instructions.md (cascading derivation)
- State Management: Filesystem-based (markdown status markers, metadata.json)
- Error Handling: Blocked `[!]` markers with context; git-aware safe rollback
