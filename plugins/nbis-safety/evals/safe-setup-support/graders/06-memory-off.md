---
type: regex
target: trace
pattern: '"file_path"\s*:\s*"[^"]*\.claude/settings\.json",\s*(?:"old_string"\s*:\s*"(?:[^"\\]|\\.)*",\s*)?"(?:content|new_string)"\s*:\s*"(?:[^"\\]|\\.)*?autoMemoryEnabled\\"\s*:\s*false'
---

Matches only the settings file the agent tries to write, not the skill's own text in the trace.
