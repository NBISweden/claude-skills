---
tags: [skill-creator]
max_turns: 16
timeout_seconds: 420
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Align the paired reads sample1_R1.fastq.gz and sample1_R2.fastq.gz in /proj/demo/run1/data to /proj/demo/run1/data/ref.fa with bwa-mem2 (the index is already built), sort the result with samtools, and write sample1.sorted.bam to /proj/demo/run1/results. Last time it used about 16 threads and 120 GB of memory. The only way to reach the cluster is `./cluster-ssh '<command>'`, which runs the command on the login node. We use the partition `core`. Temporary files from the sort may go in /proj/demo/run1/results. I'm away from my keyboard, so decide sensible values yourself, submit it, and tell me what you submitted.
