# Getting Started with Draft

## Overview
Draft is a lightweight assistant that works alongside **Claude Code** or **Cursor** to turn a high-level idea into a fully-tracked development workflow. It generates `spec.md` and `plan.md`, keeps your work Git-tracked, and can sync tasks with Jira—all without manual boilerplate.

## Prerequisites
* **Claude Code** or **Cursor** installed and configured for your language stack.
* A Git repository (the current `draft` folder is already a repo).
* Optional: Jira MCP server configured if you want automatic ticket creation.

## Quick Start

1. **Initialize the project** (once per project)
   ```bash
   /draft:init
   ```
   This creates project context files: `product.md`, `tech-stack.md`, `workflow.md`, and `tracks.md`.

2. **Create a new track**
   ```bash
   /draft:new-track "Add user authentication"
   ```
   This creates a **specification** (`spec.md`) and a **plan** (`plan.md`).

3. **Iterate & review**
   - Edit `spec.md` or `plan.md` to refine scope.
   - Commit the changes and push them for peer review.

4. **Preview and create Jira stories** (optional)
   Draft generates Jira tickets from `plan.md` in two steps:

   **Step 1: Preview** (generates export file for review)
   ```bash
   /draft:jira-preview [track-id]
   ```
   Creates `draft/tracks/<id>/jira-export.md` with:
   - Epic for the track
   - One story per phase
   - Auto-calculated story points (1-2 tasks = 1pt, 3-4 = 2pt, 5-6 = 3pt, 7+ = 5pt)

   **Step 2: Review and edit** the export file to adjust story points, descriptions, or acceptance criteria.

   **Step 3: Create** (pushes to Jira via MCP)
   ```bash
   /draft:jira-create [track-id]
   ```
   - Creates epic and stories in Jira
   - Updates `plan.md` with issue keys
   - If MCP-Jira unavailable, prompts for configuration

5. **Pick tasks and implement**
   - Choose one or more tasks from any phase of the plan.
   - Use the implement command to start working:
     ```bash
     /draft:implement
     ```
   - Run your local test suite (`make test` or `npm test`).

6. **Check progress**
   ```bash
   /draft:status
   ```

7. **Revert when needed**
   If a task goes sideways, run:
   ```bash
   /draft:revert
   ```
   Draft will help roll back changes associated with tasks, sparing you from complex Git commands.

## Benefits
- **Zero-setup task tracking** – Draft writes Jira tickets and updates `plan.md` for you.
- **Consistent documentation** – Every feature starts with a spec and a plan, ensuring clarity before any code is written.
- **Simplified git workflow** – `/draft:revert` and automatic commits keep the history clean.
- **Parallel work** – Pick tasks from any phase, allowing multiple engineers to work on the same feature without stepping on each other's toes.

## Possibilities
* **Feature pipelines** – Turn a spec into a series of stories, each with estimated points, and let Draft keep the backlog in sync.
* **Bug triage** – Generate a quick plan from a bug report, create a Jira ticket, and revert with a single command if the fix fails.
* **Refactoring sprints** – Draft can analyse existing code, propose a modular plan, and update documentation as you refactor.
* **On-boarding** – New engineers can bootstrap a feature by simply describing the goal; Draft handles the scaffolding, task tracking, and review checklist.

---
Start using Draft today to streamline your development workflow, reduce context-switching, and keep every step of development transparent and reversible.
