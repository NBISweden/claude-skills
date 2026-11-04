---
type: llm
focus: trace
weight: 1
---

The reply reports that k-mers spanning an N (or other non-ACGT base) are counted because the rolling window is not reset, and a test that runs against the real kmers.py fails because of it.
