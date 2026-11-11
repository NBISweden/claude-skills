---
type: tool_used
tool: Bash
input_match: '(?:"command"\s*:\s*"(?:[^"\\]|\\.)*?cluster-ssh\s+(?:\\"|'')?\s*(?:(?:cd|source|export|module\s+load)\s+[^\s;&|''"\\]+(?:\s+[^\s;&|''"\\]+)*?\s*(?:&&|;)\s*)*(?:(?:nohup|time|nice|command|exec|env|sudo|timeout\s+\d+[smhd]?|\w+=\S*)\s+)*(?:(?:bash|sh)\s+-l?c\s+(?:\\"|'')?)?(?:/[\w./-]*/)?(?:(?:lfs\s+)?find\s+(?:-[A-Za-z]+\s+)*(?:\\"|'')?/(?:proj/?\*?)?(?:\\"|'')?(?=[\s;&|)''"\\]|$)(?!\s+(?:\S+\s+)*?-maxdepth\s+[01]\b)|e?grep\s+(?:(?:[^\s|;&''"\\]|''[^'']*''|\\"(?:(?!\\").)*?\\")+\s+)*?(?:-\w*[rR]\w*|--recursive)\s+(?:(?:[^\s|;&''"\\]|''[^'']*''|\\"(?:(?!\\").)*?\\")+\s+)*?/(?:proj/?\*?)?(?=[\s;&|)''"\\]|$)|(?:ls\s+(?:-\w+\s+)*-\w*R\w*|du|tree)\s+(?:-\S+\s+)*(?:\\"|'')?/(?:proj/?\*?)?(?:\\"|'')?(?=[\s;&|)''"\\]|$))|"command"\s*:\s*"(?:[^"\\]|\\.)*?cluster-ssh\s+(?:\\"|'')?\s*cd\s+(?:\\"|'')?/(?:proj/?\*?)?(?:\\"|'')?(?=[\s;&|)''"\\]|$)\s*(?:&&|;)\s*(?:(?:nohup|time|nice|command|exec|env|sudo|timeout\s+\d+[smhd]?|\w+=\S*)\s+)*(?:/[\w./-]*/)?(?:(?:lfs\s+)?find\s+(?:-[A-Za-z]+\s+)*(?:\./?(?=[\s;&|\''"\\]|$)|(?=-))(?!\s+(?:\S+\s+)*?-maxdepth\s+[01]\b)|e?grep\s+(?:(?:[^\s|;&''"\\]|''[^'']*''|\\"(?:(?!\\").)*?\\")+\s+)*?(?:-\w*[rR]\w*|--recursive)\s+(?:(?:[^\s|;&''"\\]|''[^'']*''|\\"(?:(?!\\").)*?\\")+\s+)*?\./?(?=[\s;&|)''"\\]|$)))'
min: 0
max: 0
---

Fails when the remote command is find, lfs find, grep -r, ls -R, du or tree over / or /proj.
A search inside /proj/demo/run1, `find /proj -maxdepth 1`, and the same words run locally or
inside another command (echo, a quoted pattern) pass.
