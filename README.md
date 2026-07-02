# cast-memory — Persistent Memory for Claude Code Agents

[![CI](https://github.com/ek33450505/cast-memory/actions/workflows/ci.yml/badge.svg)](https://github.com/ek33450505/cast-memory/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-MIT-lightgrey)](LICENSE)
![Version](https://img.shields.io/badge/version-0.4.1-blue)
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
- **Relevance Scoring** — Weighted formula: `0.3 * recency + 0.2 * importance + 0.25 * fts_rank + 0.25 * cosine_sim` with per-type decay rates
- **Shared Memory Pool** — Memories with `agent='shared'` are visible to all agents
- **Procedural Memory** — `type='procedural'` stores operational patterns (BATS fixes, sandbox workarounds) auto-loaded at session start
- **Semantic Embeddings** — Optional Ollama integration generates 768-dim nomic-embed-text vectors; hybrid search combines FTS5 rank + cosine similarity
- **Session Distiller** — Extracts decisions, patterns, and failures at session end into procedural memories
- **Temporal Validity** — `valid_from`/`valid_to` columns let facts be superseded without deletion, preserving full history
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
python3 scripts/cast-session-distiller.py
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
| `valid_from` | TEXT | When this fact became true (ISO 8601) |
| `valid_to` | TEXT | When superseded (NULL = still current) |

### Virtual Tables

- `agent_memories_fts` — FTS5 index on `content` and `description`
- Sync triggers: `am_ai` (insert), `am_au` (update), `am_ad` (delete)

### Migration Scripts

Run in order for a fresh install:

1. `cast-memory-schema-v2.py` — adds `importance` and `decay_rate`
2. `cast-memory-fts5-migrate.py` — creates FTS5 virtual table and triggers
3. `cast-memory-schema-v3.py` — adds `embedding` BLOB column
4. `cast-memory-schema-v4.py` — MCP server schema additions
5. `cast-memory-migrate-temporal.py` — adds `valid_from` and `valid_to` for temporal validity

### Temporal Validity

`valid_from` and `valid_to` columns let facts be superseded without deletion — preserving history while keeping current queries clean.

```bash
python3 scripts/cast-memory-migrate-temporal.py
```

Default queries filter `WHERE valid_to IS NULL` to return only current facts:

```bash
# Include superseded memories
python3 scripts/cast-memory-router.py --mode retrieve --agent shared --prompt "test" --history

# Mark memory #42 as superseded
python3 scripts/cast-memory-router.py --invalidate 42
```

## Integration with CAST

If you use the full [CAST framework](https://github.com/ek33450505/claude-agent-team), memory persistence is already included — these scripts ship in `scripts/` and migrations run during `install.sh`. No separate install needed.

## Standalone Usage (Without CAST)

cast-memory works independently of CAST. It only requires:

- Python 3.x (uses stdlib `sqlite3`)
- A `cast.db` SQLite database (created automatically by the migration scripts)
- Optional: Ollama with `nomic-embed-text` for semantic search

The scripts read/write to `~/.claude/cast.db` by default. Override with `--db <path>` or set the `CAST_DB_URL` environment variable.

## CAST Ecosystem

> Auto-synced from [claude-agent-team/docs/ecosystem.md](https://github.com/ek33450505/claude-agent-team/blob/main/docs/ecosystem.md). Run `scripts/sync-ecosystem-readme.sh` from your claude-agent-team clone to refresh.

<!-- ECOSYSTEM_START -->
| Repo | Description | Latest | Install |
|---|---|---|---|
| [cast-mcp](https://github.com/ek33450505/cast-mcp) | Read-only MCP server over the Claude Code execution record (cast.db) — dispatch decisions, incidents, cost, sessions, and full-text search as 5 MCP tools + 5 resources. stdlib-only, strictly read-only. | ![](https://img.shields.io/github/v/release/ek33450505/cast-mcp?style=flat-square) | `brew tap ek33450505/cast-mcp && brew install cast-mcp` |
| [cast-ledger](https://github.com/ek33450505/cast-ledger) | Signed, hash-chained, tamper-evident session receipts for Claude Code — SHA-256-stamped audit receipts from cast.db with `--verify`, plus an optional provenance hash-chain across sessions. | ![](https://img.shields.io/github/v/release/ek33450505/cast-ledger?style=flat-square) | `brew tap ek33450505/cast-ledger && brew install cast-ledger` |
| [cast-predict](https://github.com/ek33450505/cast-predict) | Telemetry-driven dispatch prediction for Claude Code — reads cast.db to predict a task's likely cost, suggest agents, and surface related past incidents before you run it. | ![](https://img.shields.io/github/v/release/ek33450505/cast-predict?style=flat-square) | `brew tap ek33450505/cast-predict && brew install cast-predict` |
| [cast-memory](https://github.com/ek33450505/cast-memory) | Persistent agent memory for Claude Code — FTS5 full-text search, weighted relevance, temporal validity, Ollama embeddings, and weekly consolidation over cast.db. | ![](https://img.shields.io/github/v/release/ek33450505/cast-memory?style=flat-square) | `brew tap ek33450505/cast-memory && brew install cast-memory` |
| [cast-doctor](https://github.com/ek33450505/cast-doctor) | Standalone read-only health check for any Claude Code install — validates hooks, MCP config, agent frontmatter, cast.db core schema, and stale memories without the full CAST framework. | ![](https://img.shields.io/github/v/release/ek33450505/cast-doctor?style=flat-square) | `brew tap ek33450505/cast-doctor && brew install cast-doctor` |
| [cast-time](https://github.com/ek33450505/cast-time) | Gives Claude Code a clock — injects local time, timezone, and a semantic time-of-day bucket at every SessionStart. | ![](https://img.shields.io/github/v/release/ek33450505/cast-time?style=flat-square) | `brew tap ek33450505/cast-time && brew install cast-time` |
| [cast-claudes_journal](https://github.com/ek33450505/cast-claudes_journal) | Three-hook journaling for Claude Code (Stop/SessionStart/UserPromptSubmit) — maintains Claude's perspective and working memory across sessions as Obsidian-compatible markdown in ~/Documents/Claude/. | ![](https://img.shields.io/github/v/release/ek33450505/cast-claudes_journal?style=flat-square) | `brew tap ek33450505/homebrew-claudes-journal && brew install claudes-journal` |
| [cast-website](https://github.com/ek33450505/cast-website) | castframework.dev — marketing site and docs portal for the CAST ecosystem. | — | — |
| [cast-desktop](https://github.com/ek33450505/cast-desktop) | Tauri 2 native app — embedded PTY terminal, command palette, 11 dashboard views. | ![](https://img.shields.io/github/v/release/ek33450505/cast-desktop?style=flat-square) | `brew tap ek33450505/homebrew-cast-desktop && brew install cast-desktop` |
<!-- ECOSYSTEM_END -->

## License

MIT — see [LICENSE](LICENSE).
