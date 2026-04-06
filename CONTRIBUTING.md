# Contributing to cast-memory

Thank you for your interest in contributing to cast-memory — persistent memory for Claude Code agents.

## Prerequisites

- Python 3.9+
- SQLite3
- Bash 4.0+ (for shell scripts)
- Optional: [Ollama](https://ollama.com) with `nomic-embed-text` model for semantic search

## Quick Start

```bash
git clone https://github.com/ek33450505/cast-memory.git
cd cast-memory
bash install.sh
```

## Project Structure

```
scripts/           # Python scripts (memory router, embeddings, MCP server, etc.)
examples/          # Usage examples
install.sh         # Installer
VERSION            # Semver version file
```

## Running Tests

```bash
pytest tests/
```

## PR Checklist

Before opening a pull request:

- [ ] All existing tests pass
- [ ] New Python scripts: include docstrings and handle missing `cast.db` gracefully
- [ ] New scripts: default to `~/.claude/cast.db` with `--db` override
- [ ] SQL changes: use `IF NOT EXISTS` and parameterized queries (no string interpolation)
- [ ] No hardcoded paths — use `$HOME` or `~/` for user-relative paths
- [ ] `CHANGELOG.md` updated for any user-visible change
