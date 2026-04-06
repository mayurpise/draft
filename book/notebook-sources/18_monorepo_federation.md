# Chapter 18: Monorepo Federation

Part VI: Enterprise· Chapter 18

4 min read

A monorepo with twelve services has twelvedraft/directories after initialization. Each service has its own architecture documentation, its own tech stack, its own context files. But nobody has a unified view of the whole system — which services depend on which, what technologies are used where, or how the pieces fit together./draft:indexbuilds that view.

## The Monorepo Context Problem

Running/draft:initon each service in a monorepo produces excellent per-service context. The auth service has a detailed.ai-context.mdexplaining its JWT validation flow. The billing service documents its Stripe integration. But cross-service questions remain unanswered: what happens when auth goes down? Which services share PostgreSQL? Is anyone still using the deprecated notification API?

/draft:indexanswers these questions by aggregating service-level context into root-level knowledge files, without deep code analysis. It reads what/draft:initalready produced and synthesizes a system-of-systems view.

## Auto-Detection

Draft detects services by scanning immediate child directories (depth=1 only, never recursive) for standard project markers:

* package.json— Node.js services
* go.mod— Go services
* Cargo.toml— Rust services
* pom.xml/build.gradle— Java services
* pyproject.toml/requirements.txt— Python services
* Dockerfile— Containerized services
* src/directory with code files
It excludesnode_modules/,vendor/,.git/, and hidden directories. Each detected directory is categorized as initialized (has adraft/subdirectory) or uninitialized. Only initialized services contribute to the index.

## What Gets Generated

/draft:indexproduces six root-level files that together form a complete system map:

### service-index.md

A directory of all detected services with their status, tech stack, dependencies, team ownership, and links to their individual context files. This is the entry point — the table of contents for the entire monorepo.

### dependency-graph.md

Cross-service dependency mapping with a Mermaid topology diagram, a dependency matrix (depends-on and depended-by for every service), and a topological implementation order. This file answers "what breaks if this service changes?" and "what must exist before this service can function?"

### tech-matrix.md

A technology distribution report showing which languages, databases, frameworks, and infrastructure components are used across which services. It identifies organizational standards (technologies used by the majority of services) and variances (services that deviate, with documented justifications).

### Synthesized Root Context

If the root-leveldraft/product.md,draft/architecture.md, anddraft/tech-stack.mdare missing or are placeholders,/draft:indexsynthesizes them from service-level data:

* product.md— Aggregated product vision from all service visions, deduplicated target users, capability matrix mapping features to services
* architecture.md— System-of-systems view with topology diagram, service directory, shared infrastructure, and cross-cutting patterns
* tech-stack.md— Organizational standards derived from majority usage, approved variances, shared libraries
After generatingarchitecture.md, the Condensation Subroutine runs to produce a root-level.ai-context.md— a token-optimized aggregate of all service knowledge.

## Root-Level vs. Service-Level Context

After indexing, the monorepo has two layers of context:

When working within a single service, the AI loads that service's context. When making cross-service decisions — adding a new API dependency, changing a shared schema, planning a migration — the AI loads root-level context.

## Service Manifests

For each initialized service,/draft:indexcreates or updates amanifest.jsoninside the service'sdraft/directory. This manifest contains the service name, type, summary, primary technology, dependencies on other services, dependents (reverse lookup), team ownership, and indexing timestamps. Manifests enable fast re-indexing without re-reading all markdown files.

## Initializing Missing Services

Running/draft:index --init-missingoffers to initialize uninitialized services. For each one, Draft prompts with four options:y(initialize this service),n(skip),all(initialize all remaining), orskip-rest(skip all remaining). This makes it practical to bring an entire monorepo under Draft management incrementally.

## Bughunt Mode

/draft:indexalso supports a bughunt aggregation mode. Running/draft:index bughuntexecutes/draft:bughuntsequentially across all initialized services (or a specified subset), then generatesdraft/bughunt-summary.md— an aggregate report showing bug counts by severity across all services, directories requiring immediate attention, and links to individual service reports.

Re-run/draft:indexafter initializing a new service, after significant architecture changes to any service, before major cross-service planning, or as part of weekly documentation hygiene. The command preserves manual edits in sections marked with<!-- MANUAL START -->and<!-- MANUAL END -->comments.

