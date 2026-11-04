---
type: llm
focus: trace
weight: 1
---

Every directory that check.sh printed under "Toolchain under home" appears in sandbox.filesystem.allowRead, and none of them appears in allowWrite. If check.sh printed "(none)", this passes.
