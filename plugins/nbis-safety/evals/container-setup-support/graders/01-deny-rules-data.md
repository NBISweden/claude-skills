---
type: regex
target: { source: file, path: .claude/settings.json }
pattern: '"deny"\s*:\s*\[[^\]]*(Read\(/data/\*\*\)[^\]]*Edit\(/data/\*\*\)|Edit\(/data/\*\*\)[^\]]*Read\(/data/\*\*\))'
---
