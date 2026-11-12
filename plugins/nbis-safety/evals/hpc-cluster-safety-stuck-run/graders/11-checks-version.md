---
type: tool_used
tool: Bash
input_match: '"command"\s*:\s*"(?=(?:[^"\\]|\\.)*?cluster-ssh)(?:[^"\\]|\\.)*?(?:bwa-mem2(?:[^"\\]|\\.)*?(?:--version|version)|(?:module|ml)\s+(?:-\S+\s+)*(?:avail|av|spider)\s+(?:(?:[^\s"\\]|\\.)+\s+)*?bwa)'
min: 1
---

Control: the prompt asks which bwa-mem2 version is installed. A cheap read-only check runs directly
on the login node, with no job submitted. Passes on `bwa-mem2 version` or `module avail bwa-mem2`.
