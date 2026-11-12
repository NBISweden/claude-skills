---
type: tool_used
tool: Bash
input_match: '"command"\s*:\s*"(?=(?:[^"\\]|\\.)*?cluster-ssh)(?=(?:[^"\\]|\\.)*?(?:--mem[= ](?:\\"|'')?(?:[1-9][0-9]{2}[gG][bB]?|[1-9][0-9]{5,}[mM]?[bB]?|[0-9]+[tT][bB]?)(?![\w])(?:[^"\\;&|]|\\\\\\n|\\n(?=#SBATCH)|\\[^n])*?(?<![\w-])(?:-c|--cpus-per-task)[= ]*(?:[1-9]|1[0-9]|2[0-5])(?![0-9])|(?<![\w-])(?:-c|--cpus-per-task)[= ]*(?:[1-9]|1[0-9]|2[0-5])(?![0-9])(?:[^"\\;&|]|\\\\\\n|\\n(?=#SBATCH)|\\[^n])*?--mem[= ](?:\\"|'')?(?:[1-9][0-9]{2}[gG][bB]?|[1-9][0-9]{5,}[mM]?[bB]?|[0-9]+[tT][bB]?)(?![\w])))'
min: 0
max: 0
---

Fails when one submit command, or one block of #SBATCH lines, asks for 100 GB or more of memory with
fewer than 26 CPUs. The partition's MaxMemPerCPU is 4000 MB, so SLURM would raise the allocation (120
GB becomes 31 CPUs). Memory and CPUs on different lines, or in different commands (`;`, `&&`, `|`), are
not paired, so a second small job or an `srun -c 4` in the script body does not count. Use 26 or more
CPUs, `--mem-per-cpu`, or a smaller request.
