---
type: tool_used
tool: Bash
input_match: '"command"\s*:\s*"(?=(?:[^"\\]|\\.)*?cluster-ssh)(?:[^"\\]|\\.)*?(?:(?<![\w.-])|(?<=\\n))(?<!(?:which|type|man|echo|grep(?:\s+-\S+)*|whereis|-v)\s+)(?:sbatch|srun)(?![\w-])(?!\s+(?:--version|--help|-V|-h)(?![\w-]))'
min: 1
---

Passes when a command that reaches the cluster uses sbatch or srun in any position (after a pipe,
a path, `time`, `if`, `bash -c`, a variable assignment). `which sbatch`, `man sbatch`, `echo sbatch`,
`grep sbatch` and `sbatch --version` do not count, so a run that only looks the command up does not
pass. This grader is deliberately lenient: it fails closed, so a correct run must not miss it.
