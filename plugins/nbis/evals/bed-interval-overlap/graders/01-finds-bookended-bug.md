---
type: llm
focus: trace
weight: 1
---

The reply reports that overlaps() treats book-ended intervals such as (chr1, 0, 10) and (chr1, 10, 20) as overlapping, which is wrong for half-open BED coordinates, and a test against the real overlap.py fails because of it.
