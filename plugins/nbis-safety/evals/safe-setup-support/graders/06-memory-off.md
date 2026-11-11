---
type: regex
target: trace
pattern: '"file_path":"[^"]*\.claude/settings\.json",(?:"old_string":"(?:[^"\\]|\\.)*",)?"(?:content|new_string)":"(?:[^"\\]|\\.)*?autoMemoryEnabled\\"\s*:\s*false'
---

Matches only the settings file the agent tries to write, not the skill's own text in the trace.
