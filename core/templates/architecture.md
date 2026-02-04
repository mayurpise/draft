# Architecture: [Name]

## System Overview

**Key Takeaway:** [One-paragraph summary of the system's purpose, primary function, and what makes it tick]

### System Architecture Diagram

```mermaid
graph TD
    subgraph Presentation["Presentation Layer"]
        A[Component/Route A]
        B[Component/Route B]
    end
    subgraph Logic["Business Logic Layer"]
        C[Service/Controller A]
        D[Service/Controller B]
    end
    subgraph Data["Data Layer"]
        E[Repository/Store]
        F[(Database)]
        G[(Cache)]
    end
    A --> C
    B --> D
    C --> E
    D --> E
    E --> F
    E --> G
```

> Replace with actual system layers and components discovered during codebase analysis.

---

## Phase 1: Orientation

### Directory Structure

| Directory | Responsibility | Key Files |
|-----------|---------------|-----------|
| `src/` | Main application code | [entry point files] |
| `tests/` | Test suites | [test config] |
| `config/` | Configuration | [env, app config] |

```mermaid
graph TD
    Root["project-root/"] --> Src["src/"]
    Root --> Tests["tests/"]
    Root --> Config["config/"]
    Src --> Models["models/"]
    Src --> Services["services/"]
    Src --> Routes["routes/"]
```

> Map top-level directories and their single-sentence responsibilities. Respect `.gitignore`.

### Entry Points & Critical Paths

| Entry Point | Type | File | Description |
|-------------|------|------|-------------|
| Application startup | Main | `src/index.ts` | Initializes app, connects DB, starts server |
| API routes | HTTP | `src/routes/` | Request handling entry |
| Background jobs | Worker | `src/jobs/` | Scheduled/queued task entry |
| CLI commands | CLI | `src/cli/` | Command-line interface entry |

> Identify primary entry points: API routes, main loops, event listeners, CLI commands, serverless handlers.

### Request/Response Flow

```mermaid
sequenceDiagram
    participant Client
    participant Router
    participant Controller
    participant Service
    participant Repository
    participant DB

    Client->>Router: HTTP Request
    Router->>Controller: Route match
    Controller->>Service: Business operation
    Service->>Repository: Data access
    Repository->>DB: Query
    DB-->>Repository: Result
    Repository-->>Service: Domain object
    Service-->>Controller: Result
    Controller-->>Client: HTTP Response
```

> Trace one representative request through the full stack. Replace with actual layers.

### Tech Stack Inventory

| Category | Technology | Version | Config File |
|----------|-----------|---------|-------------|
| Language | [e.g., TypeScript] | [e.g., 5.x] | `tsconfig.json` |
| Framework | [e.g., Express] | [e.g., 4.18] | `package.json` |
| Database | [e.g., PostgreSQL] | [e.g., 15] | `docker-compose.yml` |
| ORM | [e.g., Prisma] | [e.g., 5.x] | `prisma/schema.prisma` |
| Testing | [e.g., Jest] | [e.g., 29.x] | `jest.config.ts` |

> Auto-detected from package manager files. Cross-referenced with `draft/tech-stack.md`.

---

## Phase 2: Logic

### Data Lifecycle

```mermaid
flowchart LR
    Input["Input\n(API/Event/CLI)"] --> Validate["Validation\n& Parsing"]
    Validate --> Transform["Transform\n& Enrich"]
    Transform --> Process["Business\nLogic"]
    Process --> Persist["Persistence\n& Side Effects"]
    Persist --> Output["Response\n& Events"]
```

> Map how primary data objects enter, transform, persist, and exit the system.

### Primary Data Objects

| Object | Created At | Modified At | Persisted In | Key Fields |
|--------|-----------|-------------|--------------|------------|
| [e.g., User] | `src/auth/register.ts` | `src/user/profile.ts` | `users` table | id, email, role |
| [e.g., Order] | `src/orders/create.ts` | `src/orders/update.ts` | `orders` table | id, status, total |

> Track the lifecycle of 3-5 primary domain objects through the system.

### Design Patterns

| Pattern | Where Used | Purpose |
|---------|-----------|---------|
| [e.g., Repository] | `src/repos/` | Data access abstraction |
| [e.g., Factory] | `src/factories/` | Object creation |
| [e.g., Middleware] | `src/middleware/` | Cross-cutting concerns |
| [e.g., Observer/Events] | `src/events/` | Decoupled communication |

### Anti-Patterns & Complexity Hotspots

| Location | Issue | Severity | Notes |
|----------|-------|----------|-------|
| [e.g., `src/legacy/handler.ts`] | [e.g., God function, 500+ lines] | High | [Unknown/Legacy Context Required] |

> Flag areas of high cyclomatic complexity, god objects, circular dependencies, or code that deviates from the dominant patterns. Mark unclear business reasons as "Unknown/Legacy Context Required".

### Conventions & Guardrails

| Convention | Pattern | Example |
|-----------|---------|---------|
| Error handling | [e.g., Custom error classes] | `throw new AppError('NOT_FOUND', 404)` |
| Logging | [e.g., Structured JSON] | `logger.info({ userId, action })` |
| Naming | [e.g., kebab-case files, PascalCase classes] | `user-service.ts`, `class UserService` |
| Validation | [e.g., Zod schemas at boundaries] | `const schema = z.object({...})` |

> Extract conventions the codebase already follows. New code must respect these.

### External Dependencies & Integrations

```mermaid
graph LR
    App["Application"] --> Auth["Auth Provider\n(e.g., OAuth)"]
    App --> Email["Email Service\n(e.g., SendGrid)"]
    App --> Storage["File Storage\n(e.g., S3)"]
    App --> Queue["Message Queue\n(e.g., Redis/SQS)"]
    App --> ThirdParty["Third-Party API\n(e.g., Stripe)"]
```

> Map external service dependencies. Identify which are critical vs. optional.

---

## Module Dependency Diagram

```mermaid
graph LR
    A["Module A"] --> B["Module B"]
    A --> C["Module C"]
    B --> D["Module D"]
    C --> D
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
- [Areas flagged as "Unknown/Legacy Context Required" need team input]
