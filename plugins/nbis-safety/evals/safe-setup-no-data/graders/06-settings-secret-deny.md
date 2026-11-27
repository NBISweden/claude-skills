---
type: regex
target: trace
pattern: '"file_path"\s*:\s*"[^"]*\.claude/settings\.json",\s*(?:"old_string"\s*:\s*"(?:[^"\\]|\\.)*",\s*)?"(?:content|new_string)"\s*:\s*"(?:[^"\\]|\\.)*?\\"deny\\"\s*:\s*\[(?:[^\]\\]|\\.)*?Read\(/\*\*/\.env\)'
---

Matches only the settings file the agent tries to write: it denies reading .env files.
