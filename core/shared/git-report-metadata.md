# Git Report Metadata

Shared procedure for gathering git metadata and generating YAML frontmatter in Draft reports.

Referenced by: `/draft:bughunt`, `/draft:deep-review`, `/draft:review`

## Git Metadata Commands

Gather git info before writing the report:

```bash
git branch --show-current                    # LOCAL_BRANCH
git rev-parse --abbrev-ref @{upstream} 2>/dev/null || echo "none"  # REMOTE/BRANCH
git rev-parse HEAD                           # FULL_SHA
git rev-parse --short HEAD                   # SHORT_SHA
git log -1 --format=%ci HEAD                 # COMMIT_DATE
git log -1 --format=%s HEAD                  # COMMIT_MESSAGE
git status --porcelain | head -1 | wc -l     # 0 = clean, >0 = dirty
```

## YAML Frontmatter Template

Every Draft report MUST include this frontmatter block at the top of the file. Replace placeholders with values from the commands above.

```yaml
---
project: "{PROJECT_NAME}"
module: "{MODULE_NAME or 'root'}"
track_id: "{TRACK_ID or null}"
generated_by: "{COMMAND_NAME}"
generated_at: "{ISO_TIMESTAMP}"
git:
  branch: "{LOCAL_BRANCH}"
  remote: "{REMOTE/BRANCH}"
  commit: "{FULL_SHA}"
  commit_short: "{SHORT_SHA}"
  commit_date: "{COMMIT_DATE}"
  commit_message: "{COMMIT_MESSAGE}"
  dirty: {true|false}
synced_to_commit: "{FULL_SHA}"
---
```

### Field Notes

- `project` — Derive from the repository name or `draft/product.md` title
- `module` — Use `"root"` for project-level reports; use the module name/path for module-level reports
- `track_id` — Set to the track ID if scoped to a track; `null` otherwise
- `generated_by` — The Draft command that produced this report (e.g., `"draft:bughunt"`, `"draft:deep-review"`, `"draft:review"`)
- `synced_to_commit` — Use the full SHA; or pull from `draft/.ai-context.md` frontmatter if available

## Report Header Table

Include this summary table immediately after the frontmatter for human readability:

```markdown
| Field | Value |
|-------|-------|
| **Branch** | `{LOCAL_BRANCH}` → `{REMOTE/BRANCH}` |
| **Commit** | `{SHORT_SHA}` — {COMMIT_MESSAGE} |
| **Generated** | {ISO_TIMESTAMP} |
| **Synced To** | `{FULL_SHA}` |
```

## Timestamped File Naming

Reports use timestamped filenames with a `-latest.md` symlink:

```bash
# Generate timestamp
TIMESTAMP=$(date +%Y-%m-%dT%H%M)

# Write report to timestamped file
# Example: draft/bughunt-report-2026-03-15T1430.md

# Create symlink to latest
ln -sf <report-filename> <report-dir>/<report-type>-latest.md
```

Previous timestamped reports are preserved. The `-latest.md` symlink always points to the most recent report.
