# cast-memory — Persistent Memory for Claude Code Agents

[![CI](https://github.com/ek33450505/cast-memory/actions/workflows/ci.yml/badge.svg)](https://github.com/ek33450505/cast-memory/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-MIT-lightgrey)](LICENSE)
![Version](https://img.shields.io/badge/version-0.1.0-blue)
![platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)

Persistent, searchable, scored memory for Claude Code agents. FTS5 full-text search, relevance scoring, shared memory pool, procedural memory patterns, semantic embeddings, MCP server access, and weekly consolidation — all backed by SQLite.

## Quick Start

```bash
brew tap ek33450505/cast-memory
brew install cast-memory
```

Or install from source:

```bash
git clone https://github.com/ek33450505/cast-memory
cd cast-memory
bash install.sh
```

## What It Does

- **FTS5 Full-Text Search** — `agent_memories_fts` virtual table with sync triggers indexes `content` and `description` columns
- **Relevance Scoring** — Weighted formula: `0.4 * recency + 0.3 * importance + 0.3 * fts_rank` with per-type decay rates
- **Shared Memory Pool** — Memories with `agent='shared'` are visible to all agents
- **Procedural Memory** — `type='procedural'` stores operational patterns (BATS fixes, sandbox workarounds) auto-loaded at session start
- **Semantic Embeddings** — Optional Ollama integration generates 768-dim nomic-embed-text vectors; hybrid search combines FTS5 rank + cosine similarity
- **Session Distiller** — Extracts decisions, patterns, and failures at session end into procedural memories
- **Staleness Validation** — Flags memories >30 days old, verifies file/function references still exist
- **MCP Server** — Wraps `agent_memories` as an MCP resource for external tool access
- **Weekly Consolidation** — Deduplicates, applies decay, archives memories below relevance threshold

## Usage

### Search memories (FTS5)

```bash
python3 scripts/cast-memory-router.py --mode retrieve --agent code-writer --prompt "BATS whitespace" --top-n 5
```

### Search with type filter

```bash
python3 scripts/cast-memory-router.py --mode retrieve --agent shared --type procedural --prompt "sandbox"
```

### Route a prompt to an agent (legacy mode)

```bash
python3 scripts/cast-memory-router.py --prompt "how to fix the test runner"
```

### Generate embeddings (requires Ollama)

```bash
# Pull the model first
ollama pull nomic-embed-text

# Backfill all existing memories
python3 scripts/cast-memory-embed.py --backfill

# Embed a single text
python3 scripts/cast-memory-embed.py --text "how to fix BATS whitespace issues"
```

### Validate memory staleness

```bash
python3 scripts/cast-memory-validate.py --check           # report only
python3 scripts/cast-memory-validate.py --validate         # update timestamps for valid
python3 scripts/cast-memory-validate.py --archive-stale    # zero importance on stale
```

### Run consolidation

```bash
python3 scripts/cast-memory-consolidate.py
```

### Distill a session

```bash
python3 scripts/cast-memory-session-distiller.py
```

### Start MCP server

```bash
python3 scripts/cast-mcp-memory-server.py
```

## Schema

All data lives in `cast.db` (SQLite, WAL mode). The `agent_memories` table is the primary store:

| Column | Type | Description |
|---|---|---|
| `id` | INTEGER | Primary key |
| `agent` | TEXT | Agent name or `'shared'` for cross-agent |
| `type` | TEXT | `project`, `feedback`, `user`, `reference`, `procedural` |
| `name` | TEXT | Memory identifier slug |
| `content` | TEXT | Memory content (markdown) |
| `description` | TEXT | Short description |
| `importance` | REAL | 0.0–1.0, weights relevance scoring |
| `decay_rate` | REAL | Per-type exponential decay (0.990–0.999) |
| `embedding` | BLOB | 768-dim float32 vector (optional, requires Ollama) |
| `created_at` | TEXT | ISO 8601 timestamp |
| `updated_at` | TEXT | ISO 8601 timestamp |

### Virtual Tables

- `agent_memories_fts` — FTS5 index on `content` and `description`
- Sync triggers: `am_ai` (insert), `am_au` (update), `am_ad` (delete)

### Migration Scripts

Run in order for a fresh install:

1. `cast-memory-schema-v2.py` — adds `importance` and `decay_rate`
2. `cast-memory-fts5-migrate.py` — creates FTS5 virtual table and triggers
3. `cast-memory-schema-v3.py` — adds `embedding` BLOB column
4. `cast-memory-schema-v4.py` — MCP server schema additions

## Integration with CAST

If you use the full [CAST framework](https://github.com/ek33450505/claude-agent-team), memory persistence is already included — these scripts ship in `scripts/` and migrations run during `install.sh`. No separate install needed.

## Standalone Usage (Without CAST)

cast-memory works independently of CAST. It only requires:

- Python 3.x (uses stdlib `sqlite3`)
- A `cast.db` SQLite database (created automatically by the migration scripts)
- Optional: Ollama with `nomic-embed-text` for semantic search

The scripts read/write to `~/.claude/cast.db` by default. Override with `--db <path>` or set the `CAST_DB_URL` environment variable.

## CAST Ecosystem

Each CAST component ships as a standalone Homebrew package. Mix and match to build your own stack.

| Package | What It Does | Install |
|---------|-------------|---------|
| [cast-agents](https://github.com/ek33450505/cast-agents) | 17 specialist Claude Code agents | `brew tap ek33450505/cast-agents && brew install cast-agents` |
| [cast-hooks](https://github.com/ek33450505/cast-hooks) | 13 hook scripts — observability, safety gates, dispatch | `brew tap ek33450505/cast-hooks && brew install cast-hooks` |
| [cast-observe](https://github.com/ek33450505/cast-observe) | Session cost + token spend tracking | `brew tap ek33450505/cast-observe && brew install cast-observe` |
| [cast-security](https://github.com/ek33450505/cast-security) | Policy gates, PII redaction, audit trail | `brew tap ek33450505/cast-security && brew install cast-security` |
| [cast-dash](https://github.com/ek33450505/cast-dash) | Terminal UI dashboard (Python + Textual) | `brew tap ek33450505/cast-dash && brew install cast-dash` |
| **cast-memory** | Persistent memory for Claude Code agents | `brew tap ek33450505/cast-memory && brew install cast-memory` |
| [cast-parallel](https://github.com/ek33450505/cast-parallel) | Parallel plan execution across dual worktrees | `brew tap ek33450505/cast-parallel && brew install cast-parallel` |

## License

MIT — see [LICENSE](LICENSE).
