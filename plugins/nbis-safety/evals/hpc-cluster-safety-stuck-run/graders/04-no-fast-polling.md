---
type: tool_used
tool: Bash
input_match: '"command"\s*:\s*"\s*(?:(?:[^"\\]|\\.)*?(?:[;&(]|\|\||(?<=\s)\|(?=\s)|\\n|cluster-ssh\s+(?:\\"|'')?)\s*(?:(?:do|then|else)\s+)?)?(?:(?:nohup|time|nice|command|exec|env|sudo|timeout\s+\d+[smhd]?|\w+=\S*)\s+)*(?:/[\w./-]*/)?(?:sleep\s+(?:(?:[0-9]|[12][0-9])(?:\.[0-9]+)?|\.[0-9]+)s?(?=[\s;&|)''"\\]|$)|watch\s+(?!(?:-\S+\s+(?:\d+\s+)?)*?(?:-\w*n\s*(?:[3-9][0-9]|[1-9][0-9]{2,})|--interval[=\s]+(?:[3-9][0-9]|[1-9][0-9]{2,}))(?![0-9]))\S|(?:while|until)\s+(?:true|:|false)\b(?!(?:[^"\\]|\\.)*?sleep\s+(?:(?:[3-9][0-9]|[1-9][0-9]{2,})|[0-9.]+[mhd]|(?:\\"|\'')?\$))|squeue\s+(?:[^\s;&|]+\s+)*?(?:-i|--iterate[=\s])\s*(?:[0-9]|[12][0-9])(?=[\s;&|)''"\\]|$))'
min: 0
max: 0
---

Fails on a command that waits or refreshes more often than every 30 seconds: `sleep` under 30,
`watch` without -n 30 or more, `squeue -i` under 30, or a while/until true loop with no sleep of
30 seconds or more (a variable interval counts). Words inside quoted text or job scripts pass.
