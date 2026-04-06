# Chapter 19: Jira Integration

Part VI: Enterprise· Chapter 19

3 min read

Draft produces specs and plans. Jira tracks issues and assigns work. The gap between them is manual: someone reads the plan, creates an epic, writes stories for each phase, adds sub-tasks for each task. This is tedious, error-prone, and inevitably drifts from the source document. Draft's Jira integration closes the gap with two commands:/draft:jira-previewto generate the export, and/draft:jira-createto push it.

## The Mapping

Draft's plan structure maps naturally to Jira's issue hierarchy:

A track with 4 phases averaging 3 tasks each produces 1 epic, 4 stories, and 12 sub-tasks. Story points are calculated automatically from task count: 1-2 tasks = 1 point, 3-4 tasks = 2 points, 5-6 tasks = 3 points, 7+ tasks = 5 points.

## Preview Before Push

/draft:jira-previewgenerates a timestampedjira-export-<timestamp>.mdfile in the track directory, with ajira-export-latest.mdsymlink for easy access. This file is a complete, editable representation of what will be created in Jira.

The preview includes:

* Epic— Summary from the track title, description from the spec overview
* Stories— One per phase, with goal and verification criteria in Jira markup, calculated story points
* Sub-tasks— One per task, with status mapped from plan markers ([ ]= To Do,[x]= Done,[~]= In Progress,[!]= Blocked)
* Bug issues— If/draft:bughuntor/draft:reviewreports exist, their findings are included as separate Bug issues with full detail: location, confidence level, code evidence, data flow trace, impact, and recommended fix
The preview file is editable. Adjust story points, rewrite descriptions, add or remove sub-tasks, change bug priorities — then run/draft:jira-createto push the edited version.

## Creating Issues

/draft:jira-createreads the export file and creates issues in Jira via MCP (Anthropic's Model Context Protocol). It automatically detects available MCP-Jira tools and adapts to the configured tool naming convention.

The creation order matters:

* Epic— Created first, capturing the epic key (e.g., PROJ-123)
* Stories— Created with epic link, one per phase
* Sub-tasks— Created under their parent story
* Bugs— Created as Bug issues linked to the epic, with severity mapped to Jira priority (Critical = Highest, High = High, Medium = Medium, Low = Low)
Each issue is persisted incrementally: after creating each issue, its Jira key is written back to the export file immediately. If the process fails mid-way (network error, API limit), re-running/draft:jira-createskips already-created items and picks up where it left off.

## Configuration

The Jira project key is stored indraft/workflow.mdunder a## Jirasection:

If the key is missing on first run, Draft prompts for it and persists the value for all future invocations. The project key is validated against the Jira API before any issues are created — an invalid key fails fast with a clear error.

## Plan Synchronization

After issue creation,/draft:jira-createupdatesplan.mdwith Jira keys inline:

This creates bidirectional traceability: the plan references Jira issues, and Jira issues contain the phase goals and verification criteria from the plan.

## Quality Reports in Jira

When/draft:reviewor/draft:bughunthas been run on the track, their findings are included in the Jira export. Review findings become an informational table in the epic description. Bug hunt findings become individual Bug issues with all evidence preserved: the code snippet, the data flow trace, the verification steps completed, the reasoning for why the finding is not a false positive, and the recommended fix with regression test.

This means the team working in Jira has the same quality intelligence that Draft produced — not a summary, but the full detail needed to act on each finding.

## Bidirectional Sync Considerations

Draft's Jira integration is currently one-directional: Draft pushes to Jira. If Jira issues are updated externally (status changes, reassignment, added comments), those changes are not pulled back into Draft'splan.md.

This is a deliberate design choice. Draft'splan.mdis the source of truth for implementation order and task status during active development. Jira is the source of truth for project management, assignment, and organizational tracking. The two systems serve different audiences and update at different cadences. The Jira keys inplan.mdprovide the link between them when cross-referencing is needed.

/draft:jira-createrequires a configured MCP-Jira server. If MCP is not available, Draft provides the export file as a complete, structured document that can be manually imported or used with other Jira integration tools. The preview command (/draft:jira-preview) works without MCP.

