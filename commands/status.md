---
description: Display current progress of tracks and active tasks
allowed-tools: Bash(git:*), Bash(cat:*), Bash(ls:*), Read
---

# Draft Status

Display a comprehensive overview of project progress.

## Gather Data

1. Read `draft/tracks.md` for track list
2. For each active track, read:
   - `draft/tracks/<id>/metadata.json` for stats
   - `draft/tracks/<id>/plan.md` for task status

## Output Format

```
═══════════════════════════════════════════════════════════
                      DRAFT STATUS
═══════════════════════════════════════════════════════════

PROJECT: [from product.md title]

ACTIVE TRACKS
─────────────────────────────────────────────────────────
[track-id-1] Feature Name
  Status: [~] In Progress
  Phase:  2/3 (Phase 2: [Phase Name])
  Tasks:  5/12 complete
  ├─ [x] Task 1.1: Description
  ├─ [x] Task 1.2: Description  
  ├─ [~] Task 2.1: Description  ← CURRENT
  ├─ [ ] Task 2.2: Description
  └─ [!] Task 2.3: Blocked - [reason]

[track-id-2] Another Feature
  Status: [ ] Not Started
  Phase:  0/2
  Tasks:  0/6 complete

BLOCKED ITEMS
─────────────────────────────────────────────────────────
• [track-id-1] Task 2.3: [blocked reason]

RECENTLY COMPLETED
─────────────────────────────────────────────────────────
• [track-id-3] - Completed [date]

QUICK STATS
─────────────────────────────────────────────────────────
Active Tracks:    2
Total Tasks:      18
Completed:        5 (28%)
Blocked:          1
═══════════════════════════════════════════════════════════
```

## If No Tracks

```
═══════════════════════════════════════════════════════════
                      DRAFT STATUS
═══════════════════════════════════════════════════════════

PROJECT: [from product.md title]

No active tracks.

Get started:
  /draft:new-track "Your feature description"

═══════════════════════════════════════════════════════════
```

## If Not Initialized

```
Draft not initialized in this project.

Run /draft:setup to initialize.
```
