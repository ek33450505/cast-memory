# cast-memory

## Install
```bash
bash install.sh
```
Runs DB migrations (v2→v4) in numerical order automatically. If running migrations manually, always run `scripts/cast-memory-schema-v*.py` in version order.

## Test
Tests in `tests/` are lint regression checks (Python `ast` + `re`), not BATS. No full integration test suite exists.
```bash
python3 -m pytest tests/
```

## Run
```bash
# Retrieve memories for an agent
python3 ~/.claude/scripts/cast-memory-router.py --mode retrieve --agent shared --prompt "search query"

# Validate memory DB integrity
python3 ~/.claude/scripts/cast-memory-validate.py --check
```

## Non-obvious
- `CAST_DB_PATH` env var overrides the default `~/.claude/cast.db` path. `install.sh` reads `CAST_DB_URL` (sqlite:/// prefix) as well.
- `--fts-only` flag on the router skips Ollama embed calls (~3s → ~30ms). Use when Ollama is unavailable.
- Semantic search requires `ollama pull nomic-embed-text` and a running Ollama daemon — not installed by default.
- CHANGELOG jumps v0.1.0 → v0.3.0 with no v0.2.0 entry; this is a known gap, not a missing release.
