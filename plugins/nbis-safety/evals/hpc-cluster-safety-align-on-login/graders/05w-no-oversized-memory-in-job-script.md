---
type: tool_used
tool: Write
input_match: '"content"\s*:\s*"(?=(?:[^"\\]|\\.)*?#SBATCH[^\\]*?--mem[= ](?:\\"|\'')?(?:[1-9][0-9]{2}[gG][bB]?|[1-9][0-9]{5,}[mM]?[bB]?|[0-9]+[tT][bB]?)(?![\w]))(?=(?:[^"\\]|\\.)*?#SBATCH[^\\]*?(?<![\w-])(?:-c|--cpus-per-task)[= ]*(?:[1-9]|[12][0-9])(?![0-9]))'
min: 0
max: 0
---

Same check as 05, for `#SBATCH` lines in a job script the agent writes to a file. A `-c` outside
a `#SBATCH` line (for example `srun -c 4`) is ignored.
