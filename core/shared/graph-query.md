# Graph Query Subroutine

Shared procedure for querying the knowledge graph from any skill. The graph provides precise, deterministic structural data about the codebase — module boundaries, dependency edges, hotspots, proto API surface, and symbol indexes.

Referenced by: `/draft:init`, `/draft:implement`, `/draft:bughunt`, `/draft:review`, `/draft:debug`, `/draft:decompose`, `/draft:index`

## Tooling Wrappers

For common query modes, prefer the deterministic wrappers under `scripts/tools/`:

| Wrapper | Graph mode | Behavior on missing graph |
|---|---|---|
| `scripts/tools/hotspot-rank.sh [--top N] [--module NAME]` | `--mode hotspots` | Emits `{hotspots:[],source:"unavailable"}` and exits 2 |
| `scripts/tools/cycle-detect.sh` | `--mode cycles` | Emits `{cycles:[],source:"unavailable"}` and exits 2 |
| `scripts/tools/mermaid-from-graph.sh [--diagram module-deps\|proto-map]` | `--mode mermaid` | Emits an empty mermaid block and exits 2 |

Use the raw `graph` CLI directly for the lower-level modes documented below.

## Pre-Check

Verify graph data exists before any graph operation:

```bash
ls draft/graph/schema.yaml 2>/dev/null
```

If absent, **skip all graph operations silently**. Graph enriches analysis — it never gates it. All skills must work identically without graph data.

## Graph Artifacts

When `draft/graph/` exists, it contains:

| File | Load | Content |
|------|------|---------|
| `schema.yaml` | Always | Metadata, stats, module list with file counts |
| `module-graph.jsonl` | Always | Module nodes + weighted inter-module dependency edges |
| `hotspots.jsonl` | Always | Files ranked by complexity score (lines + fanIn * 50) |
| `proto-index.jsonl` | Always | All proto services, RPCs, messages, enums |
| `go-index.jsonl` | When working in Go | Go functions, types, imports, `go-call` edges |
| `python-index.jsonl` | When working in Python | Python functions, classes, imports, `py-call` edges |
| `ts-index.jsonl` | When working in TS/JS | TypeScript/JS functions, classes, imports, `ts-call` edges |
| `c-index.jsonl` | When working in C/C++ | C/C++ functions, types, `c-call` edges |
| `call-index.jsonl` | When tracing call paths | All intra-file call edges across all languages |
| `hashes.json` | Never (build artifact) | Per-module SHA-256 hashes for `--incremental` builds |
| `modules/<name>.jsonl` | On demand | Per-module file graph: file nodes, include edges, cross-module edges, all language symbols + call edges |

### Per-Module JSONL Record Schema

All records in `modules/<name>.jsonl` have a `kind` field. Defined kinds:

| kind           | Fields | Description |
|----------------|--------|-------------|
| `module`       | `name, sizeKB, files` | Module metadata header (first record) |
| `file`         | `id, lines, module, sizeKB` | C++ source file node |
| `include`      | `source, target` | Intra-module C++ include edge |
| `cross-include`| `source, target` | Cross-module C++ include edge |
| `go-func`      | `name, receiver, qualified, file, module, package, line, lines` | Go function/method (`receiver=null` for top-level) |
| `go-type`      | `name, file, module, package, line, kind` | Go type (kind: struct/interface/alias/type) |
| `go-call`      | `from, to, fromFile, module, line, resolved: false, confidence` | Go intra-file call edge (tree-sitter only). `confidence: direct` for bare identifier callees, `inferred` for selector calls (`obj.Foo`) where the receiver is collapsed away. |
| `py-func`      | `name, receiver, file, module, line, lines` | Python function/method (receiver=null for top-level) |
| `py-class`     | `name, bases[], file, module, line` | Python class definition |
| `py-call`      | `from, to, fromFile, module, line, resolved: false, confidence` | Python intra-file call edge (tree-sitter only). `confidence: direct` for bare identifier callees, `inferred` for attribute calls (`obj.foo`). |
| `ts-func`      | `name, file, module, line, lines, exported, class, async` | TypeScript/JS function, method, or arrow function |
| `ts-class`     | `name, file, module, line, lines, exported, kind` | TS/JS class/interface/type (kind: class/interface/type) |
| `ts-call`      | `from, to, fromFile, module, line, resolved: false, confidence` | TS/JS intra-file call edge (tree-sitter only). `confidence: direct` for bare identifier callees, `inferred` for member calls (`obj.foo`). |
| `c-func`       | `name, file, module, line, lines, language, namespace` | C/C++ function definition |
| `c-type`       | `name, file, module, line, kind, language` | C/C++ struct/class/enum definition |
| `c-call`       | `from, to, fromFile, module, line, resolved: false, confidence` | C/C++ intra-file call edge (tree-sitter only). `confidence: direct` for bare identifier or qualified (`Foo::bar`) callees, `inferred` for field calls (`obj.foo` / `ptr->foo`). |
| `ctags-sym`    | `name, file, module, line, ctagsKind, language` | Symbol from universal-ctags (Java, Rust, Ruby, etc.) |

**Call edge notes**: All `*-call` records have `resolved: false` — callee names are syntactic (as written in source), with no type resolution. The same logical call may appear multiple times if the same function calls the target repeatedly. Call edges are **intra-file only** — cross-file resolution requires type information not available in tree-sitter.

**Confidence field**: Each `*-call` record carries a `confidence` value:
- `direct` — callee is a bare identifier (e.g. `foo()` in Go/Python/TS/C, or `Foo::bar()` in C++). Higher signal: the name appeared as written without receiver collapsing.
- `inferred` — callee is the trailing name of a member/selector/attribute/field expression (`obj.foo()`, `ptr->foo()`, `bar.foo()`). Receivers with different types collapse to the same name, so name collisions across distinct functions are likely. Treat as a candidate set, not an authoritative edge.

Skills consuming call edges (`bughunt`, `review`, `debug`) should weight `direct` edges more strongly and treat `inferred` edges as exploratory leads rather than confirmed call paths.

**Always-load files** are compact and should be read during context loading for any task that touches code structure. **Per-module files** are loaded only when working within a specific module — limit to 2-3 module files per task.

## Query Modes

The graph binary supports live queries against the built graph. Use these when you need precise answers beyond what the always-load files provide.

### Callers — who depends on this file or calls this function?

**File callers** (path with `/` or extension — uses include-edge graph):

```bash
graph --repo . --out draft/graph --query --file auth/auth.h --mode callers
```

Output: `{target, callers[{file, module, type}], summary{intra, cross, total}}`

Use when: tracing who will be affected by changing a header or interface file.

**Function callers** (bare symbol name — uses call-index.jsonl):

```bash
graph --repo . --out draft/graph --query --symbol buildGoIndex --mode callers
```

Output: `{target, callers[{func, file, module, line, kind}], total, by_module{}, note}`

Use when: finding all functions that call a specific function, across all languages. Requires call-index.jsonl (generated during full graph build with tree-sitter enabled). Results are intra-file only — cross-file callers are not resolved.

### Impact — blast radius of changing a file

```bash
graph --repo . --out draft/graph --query --file <path> --mode impact
```

Output: `{target, impact{files, modules, affected_modules[], by_category{code,test,doc,config}, files_by_depth{}, files_by_category{}}, warning}`

Each impacted file is classified as `code | test | doc | config` (matching `scripts/tools/classify-files.sh`). `by_category` gives counts; `files_by_category` gives the file lists. Use the test bucket to size regression work, the doc bucket to flag stale references, and the config bucket to spot deployment-time risk.

Use when: assessing risk before modifying a file, especially hotspot files with high fanIn.

### Hotspots — complexity ranking

```bash
graph --repo . --out draft/graph --query --mode hotspots
```

Output: `{hotspots[{id, module, lines, fanIn}]}`

Optionally filter to a module: `--symbol <module_name>`

### Modules — dependency overview with cycles

```bash
graph --repo . --out draft/graph --query --mode modules
```

Output: `{modules[], dependencies[], cycles[], summary{modules, edges, cycles, hub_modules[]}}`

### Cycles — circular dependency detection

```bash
graph --repo . --out draft/graph --query --mode cycles
```

Output: `{cycles[], count, warning}`

### Mermaid — generate diagram text from existing graph

```bash
# Both diagrams as markdown-ready fenced blocks (raw text output)
graph --repo . --out draft/graph --query --mode mermaid

# Specific diagram as JSON with metadata
graph --repo . --out draft/graph --query --mode mermaid --symbol module-deps
graph --repo . --out draft/graph --query --mode mermaid --symbol proto-map
```

**Output format split** — important for skills consuming this mode:

| Invocation | Output format | Fields |
|---|---|---|
| No `--symbol` | Raw Markdown text | Fenced ` ```mermaid ``` ` blocks ready for injection into `.ai-context.md` |
| `--symbol module-deps` | JSON | `{ mermaid: string, filtered: boolean, stats: { nodes, edges, totalNodes, totalEdges } }` |
| `--symbol proto-map` | JSON | `{ mermaid: string, stats: { services, rpcs, modules } }` |

Use the no-`--symbol` form for direct injection. Use `--symbol` forms when you need metadata (whether the diagram was filtered, edge counts) alongside the diagram text.

Note: `draft/graph/module-deps.mermaid` and `draft/graph/proto-map.mermaid` are static files written only during a full graph build (`graph --repo`). Running `--query --mode mermaid` reads the current JSONL and is always current — prefer it over the static files.

## Finding the Graph Binary

The graph binary ships with the draft plugin. Detect it at runtime using the breadcrumb file written by `install.sh`, then fallback to known paths:

```bash
GRAPH_BIN=""

# Method 1: .draft-install-path breadcrumb (written by install.sh)
for breadcrumb in \
    "$HOME/.cursor/plugins/local/draft/.draft-install-path" \
    "$HOME/.claude-plugin/../.draft-install-path" \
    ; do
    if [ -f "$breadcrumb" ]; then
        PLUGIN_ROOT="$(cat "$breadcrumb")"
        if [ -x "$PLUGIN_ROOT/graph/bin/graph" ]; then
            GRAPH_BIN="$PLUGIN_ROOT/graph/bin/graph"
            break
        fi
    fi
done

# Method 2: search common install paths
if [ -z "$GRAPH_BIN" ]; then
    for candidate in \
        "$HOME/.cursor/plugins/local/draft/graph/bin/graph" \
        "$HOME/.claude/plugins/draft/graph/bin/graph" \
        "graph/bin/graph" \
        ; do
        # "graph/bin/graph" only resolves when CWD is the plugin root
        if [ -x "$candidate" ]; then
            GRAPH_BIN="$candidate"
            break
        fi
    done
fi

# Method 3: check PATH
if [ -z "$GRAPH_BIN" ]; then
    GRAPH_BIN="$(command -v graph 2>/dev/null || true)"
fi
```

## Building the Graph

Run during `draft:init` or manually:

```bash
"$GRAPH_BIN" --repo . --out draft/graph/
```

This analyzes C/C++, Go, Python, TypeScript/JS, and Proto source files. For Java/Rust/Ruby/Swift, universal-ctags is used if installed. Excludes generated files (`*.pb.*`, `*_generated*`), test files (`*_test.cc`, `*_test.go`), and vendored code.

**Incremental rebuild** (skip unchanged modules):

```bash
"$GRAPH_BIN" --repo . --out draft/graph/ --incremental
```

Uses `hashes.json` to detect which modules changed (content-based SHA-256, not mtime). Only changed modules are re-extracted. Always-load files (module-graph, hotspots, call-index, schema) are always recomputed.

## Graceful Degradation

| Scenario | Behavior |
|----------|----------|
| No graph binary | Skip graph build in init; all skills proceed without graph data |
| Graph binary but build fails | Warn and proceed; skills work without graph data |
| `draft/graph/` exists | Load always-load files during context loading; use on-demand queries as needed |
| Stale graph data | Graph data is still useful — structural changes are infrequent. Suggest re-running init to refresh. |
