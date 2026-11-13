---
type: regex
target: { source: file, path: .claude/settings.json }
pattern: 'course-data'
match: not_contains
---
