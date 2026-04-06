# CHANGELOG

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
