---
type: regex
target: trace
pattern: '"command"\s*:\s*"(?:[^"\\]|\\.){0,400}?(?<![\w./-])(ssh|scp|rsync)\s'
match: not_contains
---
