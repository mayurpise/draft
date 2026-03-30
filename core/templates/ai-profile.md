---
project: "{PROJECT_NAME}"
module: "root"
generated_by: "draft:init"
generated_at: "{ISO_TIMESTAMP}"
git:
  branch: "{LOCAL_BRANCH}"
  remote: "{REMOTE/BRANCH}"
  commit: "{FULL_SHA}"
  commit_short: "{SHORT_SHA}"
  commit_date: "{COMMIT_DATE}"
  commit_message: "{COMMIT_MESSAGE}"
  dirty: false
synced_to_commit: "{FULL_SHA}"
---

LANG: {language} {version}
FRAMEWORK: {primary_framework} {framework_version}
DB: {database_system}
AUTH: {auth_mechanism}
API: {api_style}, {route_pattern}
TEST: {test_framework}
DEPLOY: {deployment_target}
BUILD: {build_command}
ENTRY: {entry_file} -> {entry_function}

INVARIANTS:
- {critical_invariant_1}
- {critical_invariant_2}
- {critical_invariant_3}

NEVER:
- {safety_rule_1}
- {safety_rule_2}

ACTIVE_TRACKS: {track_ids_and_names}
RECENT_CHANGES: {summary_of_recent_commits}
