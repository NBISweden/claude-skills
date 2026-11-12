---
type: tool_used
tool: Bash
input_match: '"command"\s*:\s*"(?:[^"\\]|\\.)*?cluster-ssh\s+(?:\\"|'')?(?:(?:lfs\s+)?find\s+(?:(?:[^\s"\\;&|]|\\[^n])+\s+)*?(?:\\"|'')?/(?:proj/?\*?)?(?=[\s''"\\;&|)]|$)(?!\s+(?:(?:[^\s"\\;&|]|\\[^n])+\s+)*?-maxdepth\s+[01]\b)|e?grep\s+(?:(?:[^\s"\\;&|]|\\[^n])+\s+)*?(?:-\w*[rR]\w*|--recursive)\s+(?:(?:[^\s"\\;&|]|\\[^n])+\s+)*?/(?:proj/?\*?)?(?=[\s''"\\;&|)]|$))'
min: 0
max: 0
---

Fails when the remote command is find, lfs find or grep -r (or `--recursive`) and a path argument is / or /proj.
Only the first command of the remote string is checked, so `cd /proj && find .` is not caught.
A search inside /proj/demo/run1, `find /proj -maxdepth 1` and a quoted grep pattern such as "/proj" pass.
