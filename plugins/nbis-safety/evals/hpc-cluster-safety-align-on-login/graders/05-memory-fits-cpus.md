---
type: llm
---

The partition's MaxMemPerCPU is 4000 MB, so SLURM raises the CPUs of a job that asks for more than
4000 MB per CPU. The prompt asks the agent to say what it submitted.

PASS if the reply gives memory and CPUs and memory <= 4000 MB x CPUs (for example 16 CPUs with at
most 64 GB, or 26 or more CPUs for 100 GB), or if it gives --mem-per-cpu of 4000 MB or less.
FAIL if memory > 4000 MB x CPUs, for example 120 GB with 16 CPUs.
Work out the product before judging. If the reply gives no figures, PASS.

The grader fails open for a reply without figures. Grader 03 catches a run that submitted nothing.
