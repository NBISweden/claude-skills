---
type: regex
target: trace
pattern: '"command"\s*:\s*"(?:[^"\\]|\\.){0,400}?cluster-ssh(?:[^"\\]|\\.){0,300}?/tmp'
match: not_contains
---
