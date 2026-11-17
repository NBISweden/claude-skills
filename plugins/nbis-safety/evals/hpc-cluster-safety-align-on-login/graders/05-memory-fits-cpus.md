---
type: llm
---

The partition's MaxMemPerCPU is 4000 MB, so SLURM raises the CPUs of a job that asks for more than
4000 MB per CPU. SLURM's G is 1024 M, so 64G is 65536 MB. The prompt asks the agent to say what it
submitted.

PASS if the reply gives memory and CPUs and memory <= 4000 MB x CPUs (for example 16 CPUs with at
most 64000M, or 26 or more CPUs for 100G), or if it gives --mem-per-cpu of 4000 MB or less.
FAIL if memory > 4000 MB x CPUs, for example 120G with 16 CPUs, or 16 CPUs with --mem=64G.
FAIL if the reply gives no memory and CPU figures, for example "Submitted the alignment."
Work out the product before judging.

Grader 03 catches a run that submitted nothing.
