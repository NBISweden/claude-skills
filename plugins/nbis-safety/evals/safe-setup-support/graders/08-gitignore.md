---
type: regex
target: trace
pattern: '"file_path"\s*:\s*"[^"]*/\.gitignore",\s*(?:"old_string"\s*:\s*"(?:[^"\\]|\\.)*",\s*)?"(?:content|new_string)"\s*:\s*"(?:[^"\\]|\\.)*?\.claude/settings\.json|"command"\s*:\s*"(?:[^"\\]|\\.)*?\.claude/settings\.json(?:[^"\\]|\\.)*?>>?\s*\.gitignore'
---

Matches only a write to .gitignore (Write, Edit or a shell redirect), not the skill's own text.
