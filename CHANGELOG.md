# CHANGELOG

## [0.4.0] — 2026-06-15 — v8 parity: JSONL-aware distiller + cast_db hardening

### Breaking Changes
- `scripts/cast-session-distiller.py` — rewritten (PR #227 backport): JSONL-aware parser, user-prose-only filtering, writes to `_pending/` markdown queue. ZERO database writes. Replaces old blind-INSERT-into-agent_memories behavior. `--db` flag removed; `--pending-dir` and `--max-candidates` added; default `--min-importance` raised from 0.6 to 0.7.

### Changed
- `scripts/cast_db.py` — adds `managed_agent_invocations` + `eval_runs` to the backup allowlist; WAL/busy_timeout hardening (`PRAGMA busy_timeout=5000`, `journal_mode=WAL`, `synchronous=NORMAL`); tz-aware datetimes (`.now(datetime.timezone.utc)` replacing deprecated `.utcnow()`).

## [0.3.2] — 2026-06-05 — CI fix

### Fixed
- `scripts/cast-memory-router.py` — removed an unused `import uuid` (cargo-culted during the v0.3.1 flagship-parity backport) that broke the ruff `F401` CI gate.

## [0.3.1] — 2026-06-05 — Security backport + doc correctness

### Security / Correctness
- `scripts/cast_db.py` — ported security revision from flagship (claude-agent-team v7.4.1):
  - Added `ALLOWED_TABLES` set; `db_write` now validates table name against allowlist and raises on unknown tables
  - Added `_allowed_db_prefixes()` path-traversal guard; `_get_db_path()` now validates resolved DB path
  - Added `_validate_identifier()` — validates table and column names against `[a-zA-Z_][a-zA-Z0-9_]*` before interpolating into SQL
  - `db_write` and `db_execute` now return `bool` (True = success, False = failure); never-raise contract preserved
  - Added `log_hook_failure()`, `ensure_hook_failures_table()`, `ensure_tool_call_failures_table()`, `ensure_schema_columns()` — aligns with flagship API
  - Added stderr fallback in `_log_error()` when log file is unavailable

### Bug Fixes
- `install.sh` — added temporal-validity migration step (runs `cast-memory-migrate-temporal.py`); fresh installs no longer silently lack `valid_from`/`valid_to` columns, fixing `--history` and `--invalidate` degradation
- `install.sh` — corrected banner version (`v0.1.0` → `v0.3.1`)

### Docs
- `README.md` — corrected relevance formula to match router implementation: `0.3*recency + 0.2*importance + 0.25*fts_rank + 0.25*cosine_sim` (was `0.4/0.3/0.3`)
- `README.md` — removed false "Constellation 3D graph" claim from cast-desktop ecosystem entry
- `README.md` — replaced personal absolute path in ecosystem-sync comment with generic `scripts/sync-ecosystem-readme.sh`
- `SECURITY.md` — updated supported version from `0.1.x` to `0.3.x`

### Code Quality
- `scripts/cast-memory-router.py` — added Phase-15 convergence marker (matches flagship) and `import uuid` for `log_hook_failure` resolution

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
