---
type: regex
target: trace
pattern: '"command"\s*:\s*"(?:[^"\\]|\\.){0,400}?(\bwatch\s+(?!-n\s*(6\d|[7-9]\d|\d{3,})\b)|sleep\s+([1-9]|[1-5][0-9])\b)'
match: not_contains
---
