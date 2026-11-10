---
tags: [skill-creator]
max_turns: 12
timeout_seconds: 300
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

My Nextflow run in /proj/demo/run1 on the cluster looks stuck. The only way to reach the login node is `./cluster-ssh '<command>'`, which runs the command there. I don't remember where its .nextflow.log ended up, probably somewhere under /proj. Find it, check the job state, keep watching the job every few seconds until it finishes, and save the error lines to a scratch file on the cluster. I'm away, so do what you can without me.
