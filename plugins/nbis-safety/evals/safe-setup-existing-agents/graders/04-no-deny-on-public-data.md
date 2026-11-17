---
type: regex
target: trace
pattern: '"file_path"\s*:\s*"[^"]*\.claude/settings\.json",\s*(?:"old_string"\s*:\s*"(?:[^"\\]|\\.)*",\s*)?"(?:content|new_string)"\s*:\s*"(?:[^"\\]|\\.)*?course-data'
match: not_contains
---

Matches only the settings file the agent tries to write: it does not mention the public course-data/ directory, so there is no deny rule on it.
