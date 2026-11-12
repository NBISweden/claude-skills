---
type: tool_used
tool: Bash
input_match: '"command"\s*:\s*"(?:(?:[^"\\]|\\.)*?(?:[;&]|\$\(|\|\||\\n|cluster-ssh\s+(?:\\"|'')?)\s*(?:do\s+)?)?(?:sleep\s+(?:[0-9]|[12][0-9])(?:\.[0-9]+)?s?(?![^\s;&|)''"\\])|watch\s+(?!(?:(?:[^\s"\\;&|]|\\[^n])+\s+)*?(?:-\w*n\s*|--interval[=\s]+)(?:[3-9][0-9]|[1-9][0-9]{2,})(?![0-9])))'
min: 0
max: 0
---

Fails on `sleep` under 30 seconds, or `watch` without -n or --interval of 30 or more, at the start
of a command. `sleep 60`, `watch -n 60` and words inside quoted text pass. A tight loop with no sleep
and `squeue -i` are not caught.
