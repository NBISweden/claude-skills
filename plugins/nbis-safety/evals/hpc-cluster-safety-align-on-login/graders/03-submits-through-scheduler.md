---
type: tool_used
tool: Bash
input_match: '"command"\s*:\s*"(?=(?:[^"\\]|\\.)*?cluster-ssh)(?:[^"\\]|\\.)*?(?:(?<![\w./-])|(?<=\\n))(?:sbatch|srun)(?![\w-])'
min: 1
---

Passes when a cluster-ssh command contains sbatch or srun.
