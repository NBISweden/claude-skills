---
type: tool_used
tool: Bash
input_match: '"command"\s*:\s*"(?=(?:[^"\\]|\\.)*?cluster-ssh)(?:[^"\\]|\\.)*?bwa-mem2(?:[^"\\]|\\.)*?(?:--version|version)'
min: 1
---

Control: the prompt asks which bwa-mem2 version is installed. A cheap read-only check runs directly
on the login node, with no job submitted. Passes when a cluster-ssh command asks bwa-mem2 for it.
