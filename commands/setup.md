---
description: Initialize Draft project context for Context-Driven Development. Run once per project.
allowed-tools: Bash(git:*), Bash(ls:*), Bash(find:*), Bash(cat:*), Bash(mkdir:*), Read, Write, Edit
---

# Draft Setup

You are initializing a Draft project for Context-Driven Development.

## Pre-Check

First, check if already initialized:
```bash
ls draft/ 2>/dev/null
```

If `draft/` exists with `product.md`, `tech-stack.md`, `workflow.md`, and `tracks.md`:
- Announce: "Project already initialized. Use `/draft:new-track` to create a feature or `/draft:implement` to continue work."
- Stop here.

## Step 1: Project Discovery

Analyze the current directory to classify the project:

**Brownfield (Existing)** indicators:
- Has `package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`, etc.
- Has `src/`, `lib/`, or similar code directories
- Has git history with commits

**Greenfield (New)** indicators:
- Empty or near-empty directory
- Only has README or basic config

Respect `.gitignore` and `.claudeignore` when scanning.

## Step 2: Product Definition

Create `draft/product.md` through dialogue:

1. Ask about the product's purpose and target users
2. Ask about key features and goals
3. Ask about constraints or requirements

Template:
```markdown
# Product: [Name]

## Vision
[One paragraph describing what this product does and why it matters]

## Target Users
- [User type 1]: [Their needs]
- [User type 2]: [Their needs]

## Core Features
1. [Feature 1]
2. [Feature 2]
3. [Feature 3]

## Success Criteria
- [Measurable goal 1]
- [Measurable goal 2]

## Constraints
- [Technical/business constraint]
```

Present for approval, iterate if needed, then write to `draft/product.md`.

## Step 3: Product Guidelines (Optional)

Ask if they want to define product guidelines. If yes, create `draft/product-guidelines.md`:

```markdown
# Product Guidelines

## Writing Style
- Tone: [professional/casual/technical]
- Voice: [first person/third person]

## Visual Identity
- Primary colors: [if applicable]
- Typography preferences: [if applicable]

## UX Principles
- [Principle 1]
- [Principle 2]
```

## Step 4: Tech Stack

For Brownfield projects, auto-detect from:
- `package.json` → Node.js/TypeScript
- `requirements.txt` / `pyproject.toml` → Python
- `go.mod` → Go
- `Cargo.toml` → Rust

Create `draft/tech-stack.md`:

```markdown
# Tech Stack

## Languages
- Primary: [Language] [Version]
- Secondary: [if applicable]

## Frameworks
- [Framework 1]: [Purpose]
- [Framework 2]: [Purpose]

## Database
- [Database]: [Purpose]

## Testing
- Unit: [Framework]
- Integration: [Framework]
- E2E: [Framework if applicable]

## Build & Deploy
- Build: [Tool]
- CI/CD: [Platform]
- Deploy: [Target]

## Code Patterns
- Architecture: [e.g., Clean Architecture, MVC]
- State Management: [if applicable]
- Error Handling: [pattern]
```

## Step 5: Workflow Configuration

Create `draft/workflow.md` based on team preferences:

```markdown
# Development Workflow

## Test-Driven Development
- [ ] Write failing test first
- [ ] Implement minimum code to pass
- [ ] Refactor with passing tests

## Commit Strategy
- Format: `type(scope): description`
- Types: feat, fix, docs, style, refactor, test, chore
- Commit after each completed task

## Code Review
- Self-review before marking complete
- Run linter and tests before commit

## Phase Verification
- Manual verification required at phase boundaries
- Document verification steps in plan.md
```

Ask about their TDD preference (strict/flexible/none) and commit style.

## Step 6: Initialize Tracks

Create empty `draft/tracks.md`:

```markdown
# Tracks

## Active
<!-- No active tracks -->

## Completed
<!-- No completed tracks -->

## Archived
<!-- No archived tracks -->
```

## Step 7: Create Directory Structure

```bash
mkdir -p draft/tracks
mkdir -p draft/code_styleguides
```

## Completion

Announce:
"✓ Draft initialized successfully!

Created:
- draft/product.md
- draft/tech-stack.md  
- draft/workflow.md
- draft/tracks.md

Next steps:
1. Review and edit the generated files as needed
2. Run `/draft:new-track \"Your feature description\"` to start planning"
