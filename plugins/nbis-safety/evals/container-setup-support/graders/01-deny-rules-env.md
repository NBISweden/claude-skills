---
type: regex
target: { source: file, path: .claude/settings.json }
pattern: '"deny"\s*:\s*\[[^\]]*Read\(/\*\*/\.env\)'
---
