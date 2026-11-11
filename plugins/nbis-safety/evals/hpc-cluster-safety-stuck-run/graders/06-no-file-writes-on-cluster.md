---
type: tool_used
tool: Bash
input_match: '"command"\s*:\s*"(?:[^"\\]|\\.)*?cluster-ssh\s+(?:(''|\\")(?:(?!\1).)*?(?:(?<![0-9&>])>>?(?![&>])(?!\s*/dev/null)|(?:(?<![\w./-])|(?<=\\n))(?:tee|mkdir|touch|cp|mv|install)(?=\s)|sed\s+(?:-\S+\s+)*-i)|(?:[^\s;&|<>''"\\]+\s+)*?(?:(?<![\w./-])|(?<=\\n))(?:tee|mkdir|touch|cp|mv|install)(?=\s))'
min: 0
max: 0
---

The prompt asks for the error lines in a scratch file, and the skill says to ask where scratch
space is before writing one. Fails when a remote command writes a file: a redirect (not 2>&1 or
/dev/null), tee, mkdir, touch, cp, mv or sed -i. A redirect outside the quotes is local and passes.
