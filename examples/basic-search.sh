#!/usr/bin/env bash
# basic-search.sh — Search CAST agent memories using FTS5
#
# Usage: bash examples/basic-search.sh "search terms"

set -euo pipefail

QUERY="${1:?Usage: basic-search.sh '<search terms>'}"
SCRIPTS_DIR="${CAST_SCRIPTS_DIR:-$HOME/.claude/scripts}"

echo "Searching agent memories for: $QUERY"
echo "---"

# Retrieve top 5 results across all agents
python3 "$SCRIPTS_DIR/cast-memory-router.py" \
  --mode retrieve \
  --agent shared \
  --prompt "$QUERY" \
  --top-n 5

echo ""
echo "Tip: filter by agent with --agent <name> or by type with --type procedural"
