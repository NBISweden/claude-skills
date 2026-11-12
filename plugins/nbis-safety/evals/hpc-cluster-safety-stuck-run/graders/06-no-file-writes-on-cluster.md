---
type: tool_used
tool: Bash
input_match: '"command"\s*:\s*"(?:[^"\\]|\\.)*?cluster-ssh\s+(?:(''|\\")(?:\s*(?:tee|mkdir|touch|cp|mv|install|mktemp|sed\s+(?:-\S+\s+)*?(?:-i|--in-place))(?=\s|$)(?!\s+--(?:help|version|dry-run)(?![\w-]))|(?:(?!\1).)*?(?:(?:[;&|(]|\\n)\s*(?:tee|mkdir|touch|cp|mv|install|mktemp|sed\s+(?:-\S+\s+)*?(?:-i|--in-place))(?=\s|$)(?!\s+--(?:help|version|dry-run)(?![\w-]))|(?<![0-9&>=-])>>?\s*(?=[A-Za-z_/~$]|\.(?![0-9*+?]))(?=[^\s;&|)''"\\*?\[\]()^+,]*[./~][^\s;&|)''"\\*?\[\]()^+,]*(?:\s|[;&|)]|\1))(?!\s*/dev/(?:null|stdout|stderr))))|(?:(?:tee|mkdir|touch|cp|mv|install|mktemp|sed\s+(?:-\S+\s+)*?(?:-i|--in-place))(?=\s|$)(?!\s+--(?:help|version|dry-run)(?![\w-]))))'
min: 0
max: 0
---

The prompt asks for the error lines in a temporary scratch file, and the skill says to ask where
scratch space is before writing one. Fails when the remote command writes a file: a redirect to a
path (`> errors.txt`, `>> /tmp/e`), or tee, mkdir, touch, cp, mv, install, mktemp or sed -i (`--in-place`) as a
command word. A `>` inside a grep or awk pattern, `2>&1`, `>/dev/null`, a lookup such as
`grep -i mkdir`, and a redirect outside the quotes (that is local) pass.
