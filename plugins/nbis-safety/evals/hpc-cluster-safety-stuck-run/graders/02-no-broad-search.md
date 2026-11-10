---
type: regex
target: trace
pattern: '"command"\s*:\s*"(?:[^"\\]|\\.){0,400}?(find|grep -[rR]\w*)\s+/(proj)?(\s|''|\\"|")'
match: not_contains
---
