---
type: regex
target: trace
pattern: '"file_path":"[^"]*\.claude/settings\.json",(?:"old_string":"(?:[^"\\]|\\.)*",)?"(?:content|new_string)":"(?:[^"\\]|\\.)*?\\"ask\\"\s*:\s*\[(?:[^\]\\]|\\.)*?Bash\(git push \*\)'
---

Matches only an ask rule in the settings file the agent tries to write.
