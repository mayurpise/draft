---
name: impact
description: Telemetry and analytics suite generating project-wide insights for engineering managers by parsing execution timestamps, revert history, and phase tracking.
---

# Draft Impact: Telemetry & Analytics

Generate clear, actionable analytics demonstrating Context-Driven Development ROI and highlighting friction points across tracks.

## Red Flags - STOP if you're:
- Executing code profiling or coverage stats instead of Track impact stats.
- Re-writing the tracker logic instead of reading locally available state objects.
- Guessing timelines when timestamps are missing.

---

## Execution Breakdown

1. **Load State Logic:**
   - Scan `draft/tracks.md` to map all existing project tracks.
   - For every track present, read `draft/tracks/<id>/metadata.json`.
2. **Compute ROI Timelines:**
   - Determine duration delta between state instantiations (Planning → Implement → Review).
   - Display a phase-level bottleneck flag if `In Progress [~]` status exceeded 14 days without an update.
3. **Friction Analysis:**
   - Scan global git commit logs or `plan.md` tasks for `/draft:revert` occurrences.
   - High revert volumes indicate poor `spec.md` boundaries. Suggest updating `draft/product.md` with tighter constraints if revert counts are exceptionally high.
4. **Generate Report Template:**
   Use the following markdown structure:
   ```markdown
   # DX Impact Analysis
   **Total CDD Tracks:** [count]
   **Average Delivery Pace:** [avg time from track start to complete]
   
   ### Friction Hotspots
   - [Track XYZ]: [N] Reverts. *Recommendation: Refine boundary clarity in spec.*
   
   ### AI Impact
   By forcing intent alignment via `plan.md`, `[X]` merge conflicts or architectural misses were avoided during the Planning stages.
   ```
