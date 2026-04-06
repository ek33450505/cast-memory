#!/usr/bin/env bash
# cast-memory install.sh — Install CAST memory persistence into ~/.claude/
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SCRIPTS_DIR="$CLAUDE_DIR/scripts"
DB_PATH="${CAST_DB_URL#sqlite:///}"
DB_PATH="${DB_PATH:-$CLAUDE_DIR/cast.db}"

echo "cast-memory installer v0.1.0"
echo "=============================="
echo ""

# 1. Create directories
echo "[1/5] Creating directories..."
mkdir -p "$CLAUDE_DIR"
mkdir -p "$SCRIPTS_DIR"

# 2. Run migrations in order
echo "[2/5] Running database migrations..."

echo "  - Schema v2 (importance + decay_rate columns)..."
python3 "$SCRIPT_DIR/scripts/cast-memory-schema-v2.py" --db "$DB_PATH" 2>/dev/null || true

echo "  - FTS5 migration (full-text search index)..."
python3 "$SCRIPT_DIR/scripts/cast-memory-fts5-migrate.py" --db "$DB_PATH" 2>/dev/null || true

echo "  - Schema v3 (embedding BLOB column)..."
python3 "$SCRIPT_DIR/scripts/cast-memory-schema-v3.py" --db "$DB_PATH" 2>/dev/null || true

echo "  - Schema v4 (MCP server additions)..."
python3 "$SCRIPT_DIR/scripts/cast-memory-schema-v4.py" --db "$DB_PATH" 2>/dev/null || true

# 3. Copy scripts
echo "[3/5] Installing scripts to $SCRIPTS_DIR..."
cp "$SCRIPT_DIR"/scripts/*.py "$SCRIPTS_DIR/"
echo "  Installed $(find "$SCRIPT_DIR/scripts" -maxdepth 1 -name '*.py' | wc -l | tr -d ' ') scripts."

# 4. Seed procedural memories
echo "[4/5] Seeding procedural memories..."
python3 "$SCRIPT_DIR/scripts/cast-memory-seed-procedural.py" --db "$DB_PATH" 2>/dev/null || true

# 5. Summary
echo "[5/5] Done."
echo ""
echo "cast-memory installed successfully."
echo ""
echo "Scripts installed to: $SCRIPTS_DIR"
echo "Database: $DB_PATH"
echo ""
echo "Quick start:"
echo "  python3 $SCRIPTS_DIR/cast-memory-router.py --mode retrieve --agent shared --prompt 'search query'"
echo "  python3 $SCRIPTS_DIR/cast-memory-validate.py --check"
echo ""
echo "Optional — enable semantic search (requires Ollama + nomic-embed-text):"
echo "  ollama pull nomic-embed-text"
echo "  python3 $SCRIPTS_DIR/cast-memory-embed.py --backfill"
