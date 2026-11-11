---
type: tool_used
tool: Bash
input_match: '"command"\s*:\s*"(?:[^"\\]|\\.)*?cluster-ssh\s+(?:\\"|'')?\s*(?:(?:cd|source|export|module\s+load)\s+[^\s;&|''"\\]+(?:\s+[^\s;&|''"\\]+)*?\s*(?:&&|;)\s*)*(?:(?:nohup|time|nice|command|exec|env|sudo|timeout\s+\d+[smhd]?|\w+=\S*)\s+)*(?:(?:bash|sh)\s+-l?c\s+(?:\\"|'')?)?(?:/[\w./-]*/)?(?:ls(?!(?:\s+[^\s;&|''"\\]+)*?\s+(?:-[A-Za-z0-9]*d[A-Za-z0-9]*|--directory)(?=[\s;&|)''"\\]|$))(?=(?:\s+[^\s;&|''"\\]+)*?\s+(?:-[A-Za-z0-9]*l[A-Za-z0-9]*|--long)(?=[\s;&|)''"\\]|$))|ll(?=\s))(?=(?:\s+[^\s;&|''"\\]+)*?\s+(?:\\"|'')?[^\s;&|''"\\]*\bwork(?:/\*?/?)?(?=[\s;&|)''"\\]|$))'
min: 0
max: 0
---

The run's work directory holds tens of thousands of task folders (the prompt says so).
Fails on `ls -l` (any flags with l) or `ll` on a path ending in work. `ls -l` elsewhere passes.
