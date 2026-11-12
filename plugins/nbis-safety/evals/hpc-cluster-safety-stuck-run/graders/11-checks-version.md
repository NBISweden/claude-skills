---
type: regex
target: trace
pattern: '2\.9\.3'
---

Control: the prompt asks which bwa-mem2 version is installed. Passes when the transcript holds the
version the cluster prints, however the agent asked for it (`bwa-mem2 version`, `module avail bwa`).
The number is not in the prompt, the skill or the stub source.
