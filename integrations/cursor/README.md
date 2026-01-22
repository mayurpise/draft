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
@draft init               # Initialize project
@draft new-track "..."    # Create a feature track
@draft implement          # Start implementing
@draft status             # Check progress
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
│   ├── product.md        # Product vision
│   ├── tech-stack.md     # Technical choices
│   ├── workflow.md       # TDD and commit prefs
│   ├── tracks.md         # Master track list
│   └── tracks/
│       └── <track-id>/
│           ├── spec.md
│           ├── plan.md
│           └── metadata.json
```
