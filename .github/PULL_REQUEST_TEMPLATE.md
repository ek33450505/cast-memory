## Summary

-
-

## Type of Change

- [ ] New script
- [ ] Search / scoring enhancement
- [ ] Schema migration
- [ ] MCP server change
- [ ] Bug fix
- [ ] Docs only
- [ ] Refactor

## Pre-Merge Checklist

- [ ] `pytest` passes
- [ ] SQL uses `IF NOT EXISTS` and parameterized queries
- [ ] Scripts default to `~/.claude/cast.db` with `--db` override
- [ ] No hardcoded paths (use `$HOME` or `~/`)
- [ ] `CHANGELOG.md` updated for user-visible changes
