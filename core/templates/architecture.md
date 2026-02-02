# Architecture: [Name]

## Overview

[Brief description: what the system/feature does, its inputs, outputs, and key constraints]

## Module Dependency Diagram

```
[Module A] ──> [Module B]
     │              │
     └──> [Module C] ──> [Module D]
```

## Dependency Table

| Module | Depends On | Depended By |
|--------|-----------|-------------|
| Module A | - | Module B, Module C |
| Module B | Module A | Module D |
| Module C | Module A | Module D |
| Module D | Module B, Module C | - |

## Modules

### Module: [name]
- **Responsibility:** [one sentence]
- **Files:** [expected source files]
- **API Surface:** [Use language-specific format from `core/agents/architect.md`. Examples:]
  - TypeScript: `createUser(data: CreateUserInput): Promise<User>`, `interface UserRepository { ... }`
  - Python: `create_user(data: CreateUserInput) -> User`, `class UserRepository(Protocol): ...`
  - Go: `func CreateUser(data CreateUserInput) (*User, error)`, `type UserRepository interface { ... }`
  - Rust: `pub fn create_user(data: CreateUserInput) -> Result<User, Error>`, `pub trait UserRepository { ... }`
- **Dependencies:** [which modules it imports from]
- **Complexity:** [Low / Medium / High]
- **Story:** [placeholder - filled during `/draft:implement`. See `core/agents/architect.md` Story Lifecycle for format. Will become a summary + file reference, e.g.: "Documented in `src/auth.ts:1-12` — validates token, resolves user, checks permissions"]
- **Status:** [ ] Not Started

### Module: [name]
- **Responsibility:** [one sentence]
- **Files:** [expected source files]
- **API Surface:** [Use language-specific format — see first module example above]
- **Dependencies:** [which modules it imports from]
- **Complexity:** [Low / Medium / High]
- **Story:** [placeholder - filled during `/draft:implement`. See `core/agents/architect.md` Story Lifecycle for format. Will become a summary + file reference, e.g.: "Documented in `src/auth.ts:1-12` — validates token, resolves user, checks permissions"]
- **Status:** [ ] Not Started

## Implementation Order

1. [Module with no dependencies] (leaf node)
2. [Module depending on #1]
3. [Module depending on #1]
4. [Module depending on #2 and #3]

## Notes

- [Architecture decisions, trade-offs, or constraints worth documenting]
