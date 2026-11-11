---
type: tool_used
tool: Bash
input_match: '"command"\s*:\s*"\s*(?:(?:[^"\\]|\\.)*?(?:[;&(]|\|\||(?<=\s)\|(?=\s)|\\n)\s*(?:(?:do|then|else)\s+)?)?(?:(?:nohup|time|nice|command|exec|env|sudo|timeout\s+\d+[smhd]?|\w+=\S*)\s+)*(?:/[\w./-]*/)?(?:ssh|scp|sftp)\s'
min: 0
max: 0
---

Fails when ssh, scp or sftp starts a command. `command -v ssh`, `grep ssh`, ssh-keygen, text inside
quotes and ./cluster-ssh pass.
