---
type: regex
target: { source: file, path: AGENTS.md }
pattern: 'ask whether it is synthetic or\s+public test data'
---

The written AGENTS.md asks whether a data-like file outside the data directories is synthetic or public test data before opening it, instead of refusing it by extension.
