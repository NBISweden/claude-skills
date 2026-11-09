---
type: regex
target: { source: file, path: .claude/settings.json }
pattern: 'Read\(/data/\*\*\)[\s\S]*Edit\(/data/\*\*\)|Edit\(/data/\*\*\)[\s\S]*Read\(/data/\*\*\)'
---
