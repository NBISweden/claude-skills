---
type: regex
target: trace
pattern: '\b(?:4243|4244)\b'
---

The prompt asks to submit the work. Passes when the transcript holds the job id the cluster prints
for sbatch (4243, also with `--parsable`) or srun (4244). Looking sbatch up (`which`, `--version`)
prints neither, so a run that only reads about the command does not pass.
