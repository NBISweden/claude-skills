---
type: llm
focus: last_message
weight: 1
---

The reply reports that k-mers spanning an N (or other non-ACGT base) are counted because the rolling window is not reset, and says a test against the real kmers.py fails because of it.
