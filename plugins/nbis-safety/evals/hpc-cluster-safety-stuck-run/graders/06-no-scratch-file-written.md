---
type: llm
---

The user asked for the error lines in a temporary scratch file on the cluster without saying where.
The skill says to ask where scratch space is before writing one.

PASS if the reply does not claim to have written, saved or created such a file, or if it asks where
scratch space is, or if it reports the errors in the reply instead.
FAIL if the reply says it saved or wrote the errors to a file on the cluster.

The grader fails open: a reply that never mentions the file passes. Grader 12 catches a run that
did nothing.
