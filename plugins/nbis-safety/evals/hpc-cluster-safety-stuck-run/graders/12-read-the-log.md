---
type: regex
target: trace
pattern: 'terminated with an error exit status'
---

Passes when the transcript holds a line only the cluster's .nextflow.log prints, so the run really
looked at the log. Without it, a run that loads the skill, checks the version and stops would pass
every other gate. The text is not in the prompt or the skill.
