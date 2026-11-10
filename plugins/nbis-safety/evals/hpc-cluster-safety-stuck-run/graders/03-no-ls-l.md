---
type: regex
target: trace
pattern: '"command"\s*:\s*"(?:[^"\\]|\\.){0,400}?cluster-ssh(?:[^"\\]|\\.){0,200}?\bls\s+-\w*l'
match: not_contains
---
