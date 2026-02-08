# Draft for Cursor

Context-Driven Development rules for Cursor IDE.

## Installation

Copy `.cursorrules` to your project root:

```bash
cp .cursorrules /path/to/your/project/.cursorrules
```

Or symlink it:

```bash
ln -s /path/to/draft/integrations/cursor/.cursorrules /path/to/your/project/.cursorrules
```

## Usage

Once installed, use these commands in Cursor chat:

```
@draft                    # Show overview and commands
@draft init               # Initialize project (once)
@draft new-track "..."    # Create a feature track
@draft decompose          # Module decomposition
@draft implement          # Start implementing
@draft coverage           # Code coverage report
@draft validate           # Codebase quality validation
@draft bughunt            # Systematic bug discovery
@draft status             # Check progress
@draft revert             # Git-aware rollback
@draft jira-preview       # Generate Jira export file
@draft jira-create        # Create Jira issues via MCP
```

Or use natural language - Cursor will recognize phrases like:
- "set up the project"
- "new feature: add user auth"
- "what's the status"

## Project Structure

After setup, your project will have:

```
your-project/
├── .cursorrules          # Draft rules
├── draft/
│   ├── product.md              # Product vision and goals
│   ├── product-guidelines.md   # Style, branding, UX standards (optional)
│   ├── tech-stack.md           # Technical choices
│   ├── workflow.md             # TDD and commit preferences
│   ├── jira.md                 # Jira project configuration (optional)
│   ├── tracks.md               # Master track list
│   └── tracks/
│       └── <track-id>/
│           ├── spec.md         # Requirements
│           ├── plan.md         # Phased task breakdown
│           ├── metadata.json   # Status and timestamps
│           └── jira-export.md  # Jira stories for export (optional)
```
