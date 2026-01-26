# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-25

### Added
- `/draft:init` - Initialize project context with product, tech-stack, and workflow definitions
- `/draft:new-track` - Create feature/bug/refactor tracks with spec.md and plan.md
- `/draft:implement` - Execute tasks with optional TDD workflow (RED → GREEN → REFACTOR)
- `/draft:status` - Display comprehensive progress overview
- `/draft:revert` - Git-aware rollback of tasks, phases, or entire tracks
- Cursor IDE integration via `.cursorrules`
- Quality disciplines: verification before completion, systematic debugging, two-stage review
- Specialized agents: planner, debugger, reviewer
