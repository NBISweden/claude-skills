---
type: tool_used
tool: Bash
input_match: '"command"\s*:\s*"(?=(?:[^"\\]|\\.)*?cluster-ssh)(?=(?:[^"\\]|\\.)*?(?:(?<![\w.-])(?:sbatch|srun|salloc)(?![\w-])|#SBATCH)(?:[^"\\;&|#]|#(?=SBATCH)|\\\\\\n|\\n(?=#SBATCH)|\\[^n"])*?(?:--mem[= ](?:\\"|'')?(?:[1-9][0-9]{2}[gG][bB]?|(?!100000(?![0-9]))[1-9][0-9]{5,}[mM]?[bB]?|[0-9]+[tT][bB]?)(?![\w])(?:[^"\\;&|#]|#(?=SBATCH)|\\\\\\n|\\n(?=#SBATCH)|\\[^n"])*?(?<![\w-])(?:-c|--cpus-per-task)[= ]*(?:[1-9]|1[0-9]|2[0-5])(?![0-9])|(?<![\w-])(?:-c|--cpus-per-task)[= ]*(?:[1-9]|1[0-9]|2[0-5])(?![0-9])(?:[^"\\;&|#]|#(?=SBATCH)|\\\\\\n|\\n(?=#SBATCH)|\\[^n"])*?--mem[= ](?:\\"|'')?(?:[1-9][0-9]{2}[gG][bB]?|(?!100000(?![0-9]))[1-9][0-9]{5,}[mM]?[bB]?|[0-9]+[tT][bB]?)(?![\w])))'
min: 0
max: 0
---

Fails when a `sbatch`, `srun` or `salloc` command, or a block of #SBATCH lines, asks for more memory than
the partition's MaxMemPerCPU (4000 MB) covers for 25 or fewer CPUs: 100 GB or more, or more than 100000 MB.
SLURM would raise the allocation (120 GB becomes 31 CPUs). An exact fit (`-c 25 --mem=100000M`) passes.
Memory and CPUs must sit in the same command or #SBATCH block, so a second small job, an `srun -c 4`,
an `echo` that quotes the options, and a `#` comment do not count. A violation with an inline comment
between the two #SBATCH lines is missed. Use 26 or more CPUs, `--mem-per-cpu`, or a smaller request.
