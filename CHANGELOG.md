# CHANGELOG

## [0.3.0] — 2026-05-11 — CAST v7 Sync

Brings cast-memory in line with claude-agent-team v7 canonical
scripts. Adds a shared db abstraction (`cast_db.py`) that previously
existed only inline.

### Added
- `scripts/cast_db.py` — db abstraction layer (matches the shared
  abstraction used by cast-dash and cast-hooks). All Python scripts
  now use `from cast_db import db_query, db_execute, _connect`.

### Changed
- `cast-memory-router.py` synced to v7 canonical: gains `--fts-only`
  flag, `user_profile` memory type, lightweight-agent filtering.
- `cast-session-distiller.py` refactored to use `cast_db` instead
  of raw `sqlite3`.
- `cast-memory-seed-procedural.py` updated: removed retired
  orchestrator references, now seeds the `orchestrate-skill-dispatch`
  pattern.
- `cast-memory-consolidate.py` gained `SAFE_COL` column-name
  allowlist (SQL injection mitigation backport).
- README: corrected distiller filename
  (`cast-memory-session-distiller.py` → `cast-session-distiller.py`).

### Security
- `cast-memory-consolidate.py` — column-name allowlist closes a
  SQL injection surface that existed in the standalone version
  but was already fixed in the CAST canonical.

## v0.1.0 — Initial Release (2026-04-06)

### Added
- FTS5 full-text search on `agent_memories` via `agent_memories_fts` virtual table with sync triggers
- Relevance scoring: weighted `0.4 * recency + 0.3 * importance + 0.3 * fts_rank` formula
- Shared memory pool: `agent='shared'` convention for cross-agent visibility
- Procedural memory type (`type='procedural'`) for operational patterns
- `cast-memory-router.py` — memory retrieval with `--mode`, `--agent`, `--type`, `--top-n` flags
- `cast-memory-embed.py` — semantic embeddings via Ollama nomic-embed-text (768 dims)
- `cast-session-distiller.py` — end-of-session memory extraction
- `cast-memory-validate.py` — staleness detection and file/function reference verification
- `cast-memory-consolidate.py` — weekly dedup, decay, and archive
- `cast-mcp-memory-server.py` — MCP server wrapping agent_memories table
- Migration scripts: v2 (importance/decay), FTS5, v3 (embeddings), v4 (MCP)
- `install.sh` — automated installation to `~/.claude/scripts/`
