---
type: regex
target: { source: file, path: .claude/settings.json }
pattern: '"sandbox"'
match: not_contains
---
