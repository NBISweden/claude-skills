---
type: tool_used
tool: Bash
input_match: '"command"\s*:\s*"(?:[^"\\]|\\.)*?cluster-ssh\s+(?:\\"|'')?(?:cd\s+\S+\s*(?:&&|;)\s*)?(?:ls\s+(?!(?:(?:[^\s"\;&|]|\\[^n])+\s+)*?(?:-[a-zA-Z0-9]*d[a-zA-Z0-9]*|--directory|-I|--ignore|--hide)(?=[\s=''"\\]|$))(?:(?:[^\s"\\;&|]|\\[^n])+\s+)*?(?:-[a-ce-zA-Z0-9]*l[a-ce-zA-Z0-9]*|--format=(?:long|verbose))|ll)\s+(?:(?:[^\s"\\;&|]|\\[^n])+\s+)*?[^\s;&|]*(?<![\w-])work/?(?=[\s''"\\]|$)'
min: 0
max: 0
---

The prompt says the run's work directory holds about 40,000 task folders. Fails on `ls -l` or `ls --format=long` (any
flags with l, but not -ld) or `ll` on a path that ends in work. `ls -l` elsewhere passes. The path
must come after the flags, and `ls -l -d work` is flagged.
