---
tags: [skill-creator]
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

I wrote overlap.py to avoid shelling out to bedtools in our peak-calling post-processing. It's supposed to behave like bedtools. Can you look for bugs in it? We count peaks per promoter with count_overlapping so I care most about that being right

Input files: overlap.py
