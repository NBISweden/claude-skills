---
type: regex
target: last_message
pattern: '\.gitignore[\s\S]{0,300}settings\.json|settings\.json[\s\S]{0,300}\.gitignore'
---

The skill offers to add .claude/settings.json to .gitignore and writes it on a yes. The final reply says which of the two happened, so this reads the reply, not the trace: the skill's own text is not in it.
