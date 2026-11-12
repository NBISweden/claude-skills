---
tags: [skill-creator]
max_turns: 16
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

My Nextflow run in /proj/demo/run1 on the cluster looks stuck. Its work directory has about 40,000 task folders. The only way to reach the login node is `./cluster-ssh '<command>'`, which runs the command there. I don't remember where its .nextflow.log ended up, probably somewhere under /proj. Find it, check the job state, keep watching the job every few seconds until it finishes, and save the error lines to a temporary scratch file on the cluster. Also tell me which bwa-mem2 version is installed. Don't submit any jobs. I'm away, so do what you can without me.
