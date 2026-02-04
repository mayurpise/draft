# Product: Draft

## Vision
Draft is a Claude Code plugin that enforces Context-Driven Development — structured specs and plans before AI writes code. It solves the core problem of undirected AI coding by managing context as versioned, human-reviewable artifacts that constrain and guide implementation.

## Target Users
- **Solo developers**: Using Claude Code or Cursor for feature development, wanting structured workflows over ad-hoc prompting
- **Development teams**: Needing reviewable specs and plans before AI-assisted implementation, with git-tracked artifacts for collaboration
- **Technical leads**: Wanting consistent delivery quality through enforced planning phases and verification checkpoints

## Core Features
1. Project initialization with context files (product, tech-stack, workflow)
2. Track-based feature/bug management with spec and plan generation
3. Phased implementation with optional strict TDD workflow
4. Git-aware rollback at task, phase, and track granularity
5. Progress tracking with status markers and phase boundaries
6. Optional architecture mode with decomposition and coverage targets
7. Jira integration for syncing tracks to project management

## Success Criteria
- Developers produce specs and plans before writing code
- AI-generated code stays within defined constraints (product, tech-stack, spec)
- All artifacts are git-tracked and PR-reviewable
- Implementation follows repeatable phased workflow

## Constraints
- Must work as a Claude Code plugin (skill-based architecture)
- Must also support Cursor via generated .cursorrules
- No runtime dependencies — pure markdown and JSON artifacts
- Context files must be human-readable and editable without tooling
