# Bug Hunt Report

**Branch:** `main`
**Commit:** `8ec06d6`
**Date:** 2026-02-09 00:52
**Scope:** Entire repository
**Draft Context:** Loaded (architecture.md, product.md, tech-stack.md, workflow.md)

## Summary

| Severity | Count | Confirmed | High Confidence |
|----------|-------|-----------|-----------------|
| Critical | 0 | 0 | 0 |
| High | 5 | 2 | 3 |
| Medium | 2 | 0 | 2 |
| Low | 0 | 0 | 0 |

## High Issues

### [HIGH] Correctness: Frontmatter Extraction Vulnerable to Multiple `---` Delimiters

**Location:** `scripts/build-integrations.sh:131`
**Confidence:** CONFIRMED

**Code Evidence:**
```bash
frontmatter=$(awk '/^---$/{flag=!flag;next}flag' "$file" | head -20 || true)
```

**Data Flow Trace:**
`SKILL.md` → `extract_body()` → awk toggle pattern → frontmatter validation (lines 134-142)

**Issue:** The awk pattern uses a toggle mechanism (`flag=!flag`) that flips on/off with each `---` delimiter. If a skill body contains additional `---` lines (common in markdown tables, horizontal rules, or section dividers), those sections will be incorrectly extracted as frontmatter.

**Impact:**
- Body content after a third `---` delimiter is treated as frontmatter
- Validation checks (lines 134-142) only verify that `name:` and `description:` exist somewhere in extracted text
- Could cause confusing validation errors or false positives
- Build may succeed with malformed skills

**Verification Done:**
- [x] Traced code path from extract_body entry point
- [x] Verified body extraction (lines 145-157) uses correct logic but frontmatter validation uses buggy toggle
- [x] Checked that no upstream guards exist
- [x] Confirmed validation only checks for field presence, not uniqueness

**Why Not a False Positive:**
The body extraction function (lines 145-157) correctly stops after the first closing delimiter, but the frontmatter validation uses the flawed toggle pattern. This creates an inconsistency where validation reads more content than intended.

**Fix:**
```bash
# Replace line 131 with:
frontmatter=$(awk '
    /^---$/ { if (!seen_first) { seen_first=1; next } else { exit } }
    seen_first { print }
' "$file" | head -20 || true)
```

**Regression Test:**
```bash
# Create test SKILL.md with extra --- in body
cat > test-skill.md << 'EOF'
---
name: test
description: Test skill
---

# Test Skill

Normal content
---
name: should-not-appear
description: This should not validate
---
EOF

# Run extract_body - should only extract first frontmatter block
# Expected: Only "name: test" and "description: Test skill"
# Current: Extracts both blocks, validation may pass incorrectly
```

---

### [HIGH] Correctness: Body Validation Accepts Malformed Markdown Headings

**Location:** `scripts/build-integrations.sh:482`
**Confidence:** HIGH

**Code Evidence:**
```bash
if [[ -n "$line1" ]] || [[ "$line2" != \#* ]] || [[ -n "$line3" ]]; then
    echo "ERROR: Skill '$skill' body format invalid (expected: blank, # Title, blank). Got:" >&2
```

**Data Flow Trace:**
`extract_body()` → `head -3` → line2 validation → build continues

**Issue:** The validation pattern `[[ "$line2" != \#* ]]` accepts any string starting with `#`, including invalid markdown like `#NoSpace`, `##`, `###`, or just `#`. Per CLAUDE.md specification: "The body must start with a # Title heading followed by a blank line."

**Impact:**
- Skills with malformed headings pass validation
- Generated integration files contain broken markdown
- Heading level inconsistency (`#` vs `##` vs `###`) not enforced
- CLAUDE.md states "# Title" but allows any heading level

**Verification Done:**
- [x] Checked CommonMark spec: valid headings require space after `#`
- [x] Verified CLAUDE.md requirement at line 234
- [x] Tested pattern accepts `##`, `###`, `#NoSpace`
- [x] Confirmed no downstream sanitization

**Why Not a False Positive:**
Build script currently succeeds with any `#` prefix. Checked all 15 skills - they follow convention, but validation doesn't enforce it. Future skill additions could violate without detection.

**Fix:**
```bash
# Replace line 482 with stricter pattern:
if [[ -n "$line1" ]] || [[ ! "$line2" =~ ^#\ .+ ]] || [[ -n "$line3" ]]; then
    echo "ERROR: Skill '$skill' body format invalid (expected: blank, '# Title', blank). Got:" >&2
```

**Regression Test:**
```bash
# Test invalid heading formats
test_cases=(
    "##NoSpace"
    "# "
    "######"
    "#"
)

for heading in "${test_cases[@]}"; do
    # Should FAIL validation but currently PASSES
    echo "$heading" | grep -q "^#\*" && echo "PASS (incorrect)" || echo "FAIL (expected)"
done
```

---

### [HIGH] Reliability: Draft File Cleanup After Rename Creates Inconsistent State

**Location:** `skills/new-track/SKILL.md:348, 394, 443-445`
**Confidence:** CONFIRMED

**Code Evidence:**
```markdown
## Step 5: Finalize Spec
2. Rename spec-draft.md → spec.md

## Step 7: Generate Implementation Plan
2. Rename plan-draft.md → plan.md

## Step 8: Create Metadata & Update Tracks
### Cleanup
Remove draft files if they still exist:
- Delete `spec-draft.md` (now `spec.md`)
- Delete `plan-draft.md` (now `plan.md`)
```

**Data Flow Trace:**
Step 5 renames spec-draft.md → Step 7 renames plan-draft.md → Step 8 attempts cleanup → files already gone

**Issue:** Lines 443-445 attempt to delete files that were already renamed in Steps 5 and 7. The cleanup will fail silently (files don't exist). More critically, if rename operations fail (permissions, filesystem issues), Step 8 proceeds to create metadata.json and update tracks.md anyway, leaving inconsistent state.

**Impact:**
- Cleanup fails silently every time (expected behavior)
- If renames fail: tracks.md shows track exists, but track has draft files instead of final files
- `/draft:implement` will fail to find spec.md and plan.md
- Manual intervention required to detect and fix

**Verification Done:**
- [x] Traced all three steps sequentially
- [x] Confirmed no error handling for failed renames
- [x] Verified Step 8 executes unconditionally
- [x] Checked no validation that spec.md and plan.md exist before metadata creation

**Why Not a False Positive:**
The instruction sequence is explicit: rename in Steps 5 and 7, then delete the same files in Step 8. This is logically inconsistent - you cannot delete files that were already renamed.

**Fix:**
```markdown
## Step 8: Create Metadata & Update Tracks

### Pre-Validation
Verify final files exist before creating metadata:
- Check `spec.md` exists
- Check `plan.md` exists
- If either missing: ERROR and halt

### Cleanup
Remove draft files if they still exist (defensive cleanup for failed renames):
- `rm -f spec-draft.md` (use -f for idempotency)
- `rm -f plan-draft.md`
```

**Regression Test:**
Simulate filesystem failure during rename:
```bash
# Setup
mkdir -p draft/tracks/test-track
touch draft/tracks/test-track/spec-draft.md
chmod 000 draft/tracks/test-track  # Deny write

# Execute Steps 5-8
# Expected: Step 5 rename fails, Step 8 detects and halts
# Current: Step 5 rename fails, Step 8 creates metadata.json, tracks.md updated, inconsistent state
```

---

### [HIGH] Reliability: No Atomicity Between metadata.json and tracks.md Updates

**Location:** `skills/new-track/SKILL.md:404-439`
**Confidence:** HIGH

**Code Evidence:**
```markdown
### Create `draft/tracks/<track_id>/metadata.json`:
{
  "id": "<track_id>",
  ...
}

### Update `draft/tracks.md`:
Add under Active:
...
```

**Data Flow Trace:**
Create metadata.json → Update tracks.md → (if interrupted: orphaned track)

**Issue:** The skill creates metadata.json first, then updates tracks.md. If interrupted between these operations, the track directory and metadata.json exist but tracks.md is not updated. This creates an orphaned track invisible to `/draft:status`.

**Impact:**
- **Case 1:** metadata.json exists, tracks.md not updated → Track invisible to status but files exist
- **Case 2:** Next `/draft:new-track` with similar name might collide or create duplicate
- **Case 3:** User manually edits tracks.md to add the orphaned track, but metadata timestamps are wrong

**Verification Done:**
- [x] Traced execution sequence in new-track skill
- [x] Checked `/draft:status` reads from tracks.md (confirmed in status/SKILL.md:24)
- [x] Verified no pre-flight check for existing metadata.json before creating new track
- [x] Confirmed no rollback mechanism for partial track creation

**Why Not a False Positive:**
The two file writes are independent operations with no transaction semantics. System crash, Ctrl+C, or LLM context limit between the operations leaves inconsistent state.

**Fix:**
```markdown
### Create `draft/tracks/<track_id>/metadata.json`:
[JSON content]

### Pre-Validation
Before updating tracks.md, verify:
- metadata.json was written successfully
- metadata.json is valid JSON

### Update `draft/tracks.md`:
[Update logic]

### Post-Validation
Verify tracks.md contains the new track entry before announcing completion.
```

**Regression Test:**
```bash
# Simulate interruption between metadata.json and tracks.md
mkdir -p draft/tracks/orphan-track
echo '{"id":"orphan-track",...}' > draft/tracks/orphan-track/metadata.json
# Don't update tracks.md

# Run /draft:status
# Expected: Should detect orphan and warn or auto-repair
# Current: Track invisible, no warning
```

---

### [HIGH] Reliability: Task Completion Leaves Inconsistent State on Failure

**Location:** `skills/implement/SKILL.md:217-230`
**Confidence:** HIGH

**Code Evidence:**
```markdown
1. Commit FIRST (REQUIRED - non-negotiable):
   - Stage only files changed by this task
   - `git add <specific files>`
   - `git commit -m "type(<track_id>): task description"`

2. Update `plan.md`:
   - Change `[ ]` to `[x]` for the completed task
   - Add the commit SHA next to the task

3. Update `metadata.json`:
   - Increment `tasks.completed`
   - Update `updated` timestamp
```

**Data Flow Trace:**
git commit succeeds → update plan.md → update metadata.json → (if interrupted: state diverges)

**Issue:** If the commit succeeds but plan.md or metadata.json update fails:
- Git history shows task committed
- plan.md still shows task as incomplete `[ ]`
- metadata.json shows incorrect task count
- Recovery is difficult: skill looks for first `[ ]` task, but code already exists

**Impact:**
- Restarting `/draft:implement` re-executes already-committed task
- Duplicate work or merge conflicts
- Progress tracking becomes unreliable
- Manual plan.md edits required to recover

**Verification Done:**
- [x] Traced three-step sequence
- [x] Confirmed git commit happens first (line 217)
- [x] Verified plan.md update depends on getting commit SHA from step 1
- [x] Checked no rollback mechanism if step 2 or 3 fails
- [x] Confirmed `/draft:implement` uses plan.md markers to find next task (implement/SKILL.md:45-50)

**Why Not a False Positive:**
The skill explicitly states "Commit FIRST" with no recovery protocol. Git is a persistent store; file edits are not atomic. Failure between steps leaves git and plan state diverged.

**Fix:**
```markdown
1. **Pre-commit validation:**
   - Verify all tests pass
   - Verify task requirements met

2. **Commit with tentative marker:**
   - git commit as normal
   - Get commit SHA: `git rev-parse HEAD`

3. **Update state atomically:**
   - Write plan.md with `[x]` and commit SHA
   - Write metadata.json with incremented counters
   - If EITHER fails:
     - Mark task as `[!]` Blocked - "State update failed after commit <SHA>"
     - Require manual intervention

4. **Verification:**
   - Read back plan.md and metadata.json
   - Confirm changes persisted
```

**Regression Test:**
```bash
# Simulate filesystem full after commit
git commit -m "test"  # succeeds
SHA=$(git rev-parse HEAD)

# Try to write plan.md - fails (disk full)
# Expected: Task marked [!] Blocked with clear recovery steps
# Current: Task remains [ ], next implement run tries to redo it
```

---

## Medium Issues

### [MEDIUM] Reliability: Architecture Refresh Overwrites Without Backup

**Location:** `skills/init/SKILL.md:41-49`
**Confidence:** CONFIRMED

**Code Evidence:**
```markdown
2. **Architecture Refresh**: If `draft/architecture.md` exists, re-run architecture discovery
   (Phase 1, 2 & 3 from Step 1.5) and diff against the existing document:
   ...
   - Present a summary of changes for developer review before writing
```

**Data Flow Trace:**
Detect architecture.md → Re-run Phase 1, 2, 3 → Present diff → Overwrite file

**Issue:** No explicit instruction to create backup before regenerating architecture.md. If the LLM generates the file, presents it, and the user interrupts mid-write or the LLM context window fills, the original file could be corrupted or partially overwritten.

**Impact:**
- Loss of manually edited architecture.md content
- If interrupted during multi-phase generation, partial output corrupts file
- No rollback mechanism if user rejects the refresh

**Verification Done:**
- [x] Checked Step 1.5 is multi-phase with extensive file reads
- [x] Confirmed no backup instruction in refresh workflow
- [x] Verified "present summary" doesn't imply temp file creation
- [x] Checked no atomic file replacement pattern (temp → rename)

**Why Not a False Positive:**
Line 49 says "present summary for review before writing" but doesn't specify using a temporary file. Standard LLM Write tool overwrites directly. If generation is interrupted, original content is lost.

**Fix:**
```markdown
2. **Architecture Refresh**:
   a. Create backup: `cp draft/architecture.md draft/architecture.md.backup`
   b. Re-run architecture discovery → Write to `draft/architecture.md.new`
   c. Present diff: `diff draft/architecture.md draft/architecture.md.new`
   d. On user approval:
      - `mv draft/architecture.md.new draft/architecture.md`
      - `rm draft/architecture.md.backup`
   e. On user rejection:
      - `rm draft/architecture.md.new`
      - Keep original architecture.md
```

**Regression Test:**
N/A - Requires simulating LLM interruption mid-write, not reproducible in test harness.

---

### [MEDIUM] Reliability: Track Completion Three-File State Update Race

**Location:** `skills/implement/SKILL.md:306-310`
**Confidence:** HIGH

**Code Evidence:**
```markdown
2. Update `plan.md` status to `[x] Completed`
3. Update `metadata.json` status to `"completed"`
4. Update `draft/tracks.md`:
   - Move from Active to Completed section
   - Add completion date
```

**Data Flow Trace:**
Validation passes → Update plan.md → Update metadata.json → Update tracks.md → (interruption at any step)

**Issue:** Three separate file updates with no atomicity or ordering guarantees. Interruption after any step leaves inconsistent state:
- After step 2: plan.md says complete, metadata.json says in-progress
- After step 3: plan.md and metadata.json say complete, tracks.md shows Active
- `/draft:status` reads from both tracks.md and metadata.json, will show conflicting state

**Impact:**
- Status display shows wrong track state
- Track appears in both Active and Completed sections (or neither)
- Completion date missing in tracks.md but status="completed" in metadata
- Manual recovery required

**Verification Done:**
- [x] Traced three-file update sequence
- [x] Confirmed `/draft:status` reads tracks.md (status/SKILL.md:24) and metadata.json (status/SKILL.md:26)
- [x] Verified no pre-validation that all files are writable
- [x] Checked no rollback if partial update succeeds

**Why Not a False Positive:**
Three independent file writes with no transaction semantics. Each Write tool call is a separate operation that can fail independently.

**Fix:**
```markdown
## Phase Completion

1. **Pre-validation:**
   - Verify all acceptance criteria met
   - Verify all tasks `[x]` in plan.md
   - Verify no `[!]` Blocked tasks remain

2. **Prepare state updates:**
   - Determine completion timestamp
   - Prepare all three file edits mentally

3. **Execute updates in sequence:**
   - Update metadata.json status to "completed"
   - Update plan.md status to `[x] Completed`
   - Update tracks.md (move to Completed section)

4. **Post-verification:**
   - Read all three files back
   - Verify completion status is consistent
   - If ANY file shows wrong state: Mark track `[!]` Blocked with recovery steps
```

**Regression Test:**
```bash
# Simulate partial update (metadata.json succeeds, tracks.md fails)
echo '{"status":"completed",...}' > draft/tracks/test/metadata.json
# tracks.md fails to update (disk full, permissions)

# Run /draft:status
# Expected: Detect inconsistency and warn user
# Current: Shows conflicting state without warning
```

---

## Dimensions With No Findings

| Dimension | Status | Reason |
|-----------|--------|--------|
| Security | No bugs found | Path traversal protection confirmed (line 468), no command injection vectors, proper quoting throughout |
| Performance | N/A - Static markdown methodology | No runtime performance concerns; build script executes in <1s |
| Concurrency & Ordering | Partial findings | File operation races reported in Medium section; no true concurrent execution |
| State Management | Findings reported | Metadata.json vs tracks.md consistency issues documented in High/Medium sections |
| API & Contracts | N/A - No external APIs | Draft operates entirely on local filesystem; no API integration |
| Accessibility & UX | N/A - CLI tool | Markdown output rendered by IDE/browser, not controlled by Draft |
| Configuration & Build | No critical bugs | Build script validates input, generates three integration files successfully |
| Tests | N/A - Methodology project | Per workflow.md: "Draft is primarily a markdown methodology project. TDD applies to build script only." |
| Maintainability | No critical bugs | Some dead code cleanup opportunities exist but below HIGH threshold |

---

## Notes

- All bugs verified against Draft context (architecture.md, product.md, tech-stack.md)
- Focus areas: build script correctness, file operation ordering, state consistency
- Skipped N/A dimensions per Dimension Applicability Check (no backend, no UI, no external APIs)
- Framework: Bash 5.x for build script, Claude LLM interprets markdown skills (no runtime code)
- All findings cross-referenced with CLAUDE.md source-of-truth hierarchy

---

## Recommended Priority

1. **Fix Immediately (HIGH):**
   - Draft file cleanup logic (prevents track creation failures)
   - Task completion state consistency (prevents implementation loop bugs)
   - Atomicity between metadata.json and tracks.md (prevents orphaned tracks)

2. **Fix Soon (MEDIUM):**
   - Architecture refresh backup (prevents data loss on `/draft:init refresh`)
   - Track completion three-file race (prevents status display bugs)

3. **Fix When Convenient (Build Script):**
   - Frontmatter extraction toggle bug (low likelihood but easy fix)
   - Heading validation strictness (already passing for all 15 current skills)
