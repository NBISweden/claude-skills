---
type: tool_used
tool: Bash
input_match: '"command"\s*:\s*"(?=(?:[^"\\]|\\.)*?cluster-ssh)(?=(?:[^"\\]|\\.)*?(?:--mem[= ](?:\\"|\'')?(?:[1-9][0-9]{2}[gG][bB]?|[1-9][0-9]{5,}[mM]?[bB]?|[0-9]+[tT][bB]?)(?![\w])(?:[^"\\;&|]|\\.)*?(?<![\w-])(?:-c|--cpus-per-task)[= ]*(?:[1-9]|[12][0-9])(?![0-9])|(?<![\w-])(?:-c|--cpus-per-task)[= ]*(?:[1-9]|[12][0-9])(?![0-9])(?:[^"\\;&|]|\\.)*?--mem[= ](?:\\"|\'')?(?:[1-9][0-9]{2}[gG][bB]?|[1-9][0-9]{5,}[mM]?[bB]?|[0-9]+[tT][bB]?)(?![\w])))'
min: 0
max: 0
---

Fails when one submit command asks for 100 GB or more of memory with fewer than 30 CPUs. The
partition's MaxMemPerCPU is 4000 MB, so SLURM would raise the allocation to 30 CPUs. Use 30 or more
CPUs, `--mem-per-cpu`, or a smaller request. Memory and CPUs in different commands (`;`, `&&`, `|`) are
not paired. A request such as `--mem=64G -c 8` (8 GB per CPU) is not caught.
