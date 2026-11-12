---
type: regex
target: trace
pattern: '"file_path"\s*:\s*"[^"]*\.claude/settings\.json",\s*(?:"old_string"\s*:\s*"(?:[^"\\]|\\.)*",\s*)?"(?:content|new_string)"\s*:\s*"(?:[^"\\]|\\.)*?\\"ask\\"\s*:\s*\[(?:[^\]\\]|\\.)*?Bash\(git push \*\)'
---

Matches only an ask rule in the settings file the agent tries to write.
