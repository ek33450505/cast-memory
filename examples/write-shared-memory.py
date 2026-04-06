#!/usr/bin/env python3
"""
write-shared-memory.py — Write a memory to the shared pool.

Shared memories (agent='shared') are visible to all agents during retrieval.
Use this for cross-cutting knowledge like project conventions, common fixes, etc.

Usage:
  python3 examples/write-shared-memory.py "memory name" "memory content" [--type procedural]
"""

import argparse
import os
import sqlite3
import sys
from datetime import datetime, timezone

DB_PATH = os.environ.get('CAST_DB_URL', '').replace('sqlite:///', '') or \
          os.path.expanduser('~/.claude/cast.db')

DECAY_RATES = {
    'feedback': 0.999,
    'user': 0.999,
    'reference': 0.997,
    'project': 0.990,
    'procedural': 0.999,
}

DEFAULT_IMPORTANCE = {
    'feedback': 0.8,
    'user': 0.9,
    'reference': 0.6,
    'project': 0.7,
    'procedural': 0.85,
}


def main():
    parser = argparse.ArgumentParser(description='Write a shared memory')
    parser.add_argument('name', help='Memory identifier slug')
    parser.add_argument('content', help='Memory content (markdown)')
    parser.add_argument('--type', default='procedural',
                        choices=['project', 'feedback', 'user', 'reference', 'procedural'],
                        help='Memory type (default: procedural)')
    parser.add_argument('--description', default='', help='Short description')
    parser.add_argument('--db', default=DB_PATH, help='Path to cast.db')
    args = parser.parse_args()

    now = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
    importance = DEFAULT_IMPORTANCE.get(args.type, 0.7)
    decay_rate = DECAY_RATES.get(args.type, 0.995)

    conn = sqlite3.connect(args.db)
    conn.execute('''
        INSERT INTO agent_memories (agent, type, name, content, description,
                                    importance, decay_rate, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', ('shared', args.type, args.name, args.content,
          args.description or args.name, importance, decay_rate, now, now))
    conn.commit()
    conn.close()

    print(f"Wrote shared memory: {args.name} (type={args.type}, importance={importance})")


if __name__ == '__main__':
    main()
