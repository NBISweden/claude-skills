---
type: tool_used
tool: Bash
input_match: '"command"\s*:\s*"(?=(?:[^"\\]|\\.)*?cluster-ssh)(?:(?:[^"\\]|\\.)*?(?:[;&]|\$\(|\|\||\\n|cluster-ssh\s+(?:\\"|'')?)\s*(?:do\s+)?)?(?:sleep\s+(?:[0-9]|[12][0-9])(?:\.[0-9]+)?s?(?![^\s;&|)''"\\])|squeue\s+(?:(?:[^\s"\;&|]|\\[^n\s])+\s+){0,12}?(?:-i|--iterate[=\s])\s*(?:[0-9]|[12][0-9])(?![0-9])|watch\s+(?!(?:(?:[^\s"\\;&|]|\\[^n])+\s+)*?(?:-\w*n\s*|--interval[=\s]+)(?:[3-9][0-9]|[1-9][0-9]{2,})(?![0-9])))'
min: 0
max: 0
---

Fails on `sleep` under 30 seconds, or `watch` without -n or --interval of 30 or more, at the start of
a command that also reaches the cluster (`./cluster-ssh` in the same call), and on `squeue --iterate`
under 30. `sleep 60`, `watch -n 60` and words inside quoted text pass. A lone `sleep 1` or a local
`watch` with no cluster command in the same call passes, since it is not polling the cluster. A tight
loop with no sleep is not caught.
