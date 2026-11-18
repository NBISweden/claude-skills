---
type: regex
target: trace
pattern: '"file_path"\s*:\s*"[^"]*\.claude/settings\.json",\s*(?:"old_string"\s*:\s*"(?:[^"\\]|\\.)*",\s*)?"(?:content|new_string)"\s*:\s*"(?:[^"\\]|\\.)*?\\"deny\\"\s*:\s*\[(?:[^\]\\]|\\.)*?(?:Read\(/data/\*\*\)(?:[^\]\\]|\\.)*?Edit\(/data/\*\*\)|Edit\(/data/\*\*\)(?:[^\]\\]|\\.)*?Read\(/data/\*\*\))'
---

Matches only the settings file the agent tries to write: it denies both reading and editing /data.
