---
name: init
description: Initialize Draft project context for Context-Driven Development. Run once per project to create product.md, tech-stack.md, workflow.md, and tracks.md.
---

# Draft Init

You are initializing a Draft project for Context-Driven Development.

## Pre-Check

Check for arguments:
- If argument is `refresh`: Proceed to **Refresh Mode**.
- If no argument: Check if already initialized.

### Standard Init Check
```bash
ls draft/ 2>/dev/null
```

If `draft/` exists with context files:
- Announce: "Project already initialized. Use `/draft:init refresh` to update context or `/draft:new-track` to create a feature."
- Stop here.

### Refresh Mode
If the user runs `/draft:init refresh`:
1. **Tech Stack Refresh**: Re-scan `package.json`, `go.mod`, etc. Compare with `draft/tech-stack.md`. Propose updates.
2. **Product Refinement**: Ask if product vision/goals in `draft/product.md` need updates.
3. **Workflow Review**: Ask if `draft/workflow.md` settings (TDD, commits) need changing.
4. **Preserve**: Do NOT modify `draft/tracks.md` unless explicitly requested.

Stop here after refreshing. Continue to standard steps ONLY for fresh init.

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

## Step 5.5: Architecture Mode (Optional)

Ask the developer: "Enable Architecture Mode? This adds module decomposition, algorithm stories, execution state design, function skeletons, and coverage checkpoints to ALL tracks. Recommended for complex multi-module projects."

### If Yes:

Add an Architecture Mode section to `draft/workflow.md`:

```markdown
## Architecture Mode
- Enabled: Yes
- Coverage target: 95%

### What this enables:
- `/draft:decompose` to break project/tracks into modules
- Story writing (algorithm documentation) before implementation
- Execution state design before coding
- Function skeleton generation and approval
- ~200-line implementation chunk reviews
- `/draft:coverage` for test coverage measurement
```

Suggest: "Run `/draft:decompose project` after creating your first track to set up project-wide module architecture."

### If No:

Skip. Standard Draft workflow continues. Developer can enable later by adding `Architecture Mode` section to `workflow.md` manually.

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
```

## Completion

Announce:
"Draft initialized successfully!

Created:
- draft/product.md
- draft/tech-stack.md
- draft/workflow.md
- draft/tracks.md

Next steps:
1. Review and edit the generated files as needed
2. Run `/draft:new-track` to start planning a feature"
