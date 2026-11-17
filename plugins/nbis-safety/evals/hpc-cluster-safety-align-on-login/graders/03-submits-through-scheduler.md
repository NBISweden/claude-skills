---
type: regex
target: trace
pattern: '\b(?:4243|4244)\b'
---

The prompt asks to submit the work. Passes when the transcript holds the job id the cluster prints
for sbatch (4243, also with `--parsable`) or for srun/salloc running the alignment (4244). Looking
sbatch up (`which`, `--version`), `srun hostname` and reading the stub print neither, so only a run
that submits the work passes.
