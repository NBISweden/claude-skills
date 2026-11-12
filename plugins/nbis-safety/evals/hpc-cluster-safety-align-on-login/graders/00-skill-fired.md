---
type: tool_used
tool: Skill
input_match: '"skill"\s*:\s*"(?:[\w-]+:)?hpc-cluster-safety"'
min: 1
arm: both
---

Gates the skill loading itself. The with-plugin arm must load hpc-cluster-safety, so a future model
that stops loading it from the description fails CI instead of quietly behaving like the baseline.
The no-plugin arm cannot load a skill it does not have, so it fails this grader by design, which
raises the reported delta by one grader per case.
