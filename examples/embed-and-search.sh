#!/usr/bin/env bash
# embed-and-search.sh — Generate embeddings and run hybrid semantic search
#
# Requires: Ollama running locally with nomic-embed-text model
# Usage: bash examples/embed-and-search.sh "search query"

set -euo pipefail

QUERY="${1:?Usage: embed-and-search.sh '<search query>'}"
SCRIPTS_DIR="${CAST_SCRIPTS_DIR:-$HOME/.claude/scripts}"

# Step 1: Ensure embeddings exist (backfill if needed)
echo "Step 1: Checking embeddings..."
python3 "$SCRIPTS_DIR/cast-memory-embed.py" --backfill 2>/dev/null && echo "  Embeddings up to date." || echo "  Warning: Ollama not available. FTS5-only search will be used."

echo ""

# Step 2: Search with hybrid scoring (FTS5 + cosine similarity)
echo "Step 2: Searching for: $QUERY"
echo "---"
python3 "$SCRIPTS_DIR/cast-memory-router.py" \
  --mode retrieve \
  --agent shared \
  --prompt "$QUERY" \
  --top-n 5
