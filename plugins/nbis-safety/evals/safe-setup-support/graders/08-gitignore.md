---
type: regex
target: trace
pattern: '"file_path":"[^"]*/\.gitignore",(?:"old_string":"(?:[^"\\]|\\.)*",)?"(?:content|new_string)":"(?:[^"\\]|\\.)*?\.claude/settings\.json|"command":"(?:[^"\\]|\\.)*?\.claude/settings\.json(?:[^"\\]|\\.)*?>>?\s*\.gitignore'
---

Matches only a write to .gitignore (Write, Edit or a shell redirect), not the skill's own text.
