---
name: deeper
description: Turn a task into a deeper version of itself, not a bigger one, and rewrite its prompt. Use only when the user asks for it ("/deeper", "go deeper", "a deeper version of this").
disable-model-invocation: true
---

# Deeper

The user wants a deeper version of the task they name (their last request
when they name none), not a bigger one. Answer in their language.

Before rewriting anything, answer four questions, each in a few lines and
specific to this task, never generic:

1. **What a top professional would do** here that the user is not asking for.
2. **The rawest material** they would start from, instead of what has already
   been digested for the user: the source, the raw data, logs, the primary
   spec or the person's own words, not a summary, a memory or a previous
   answer.
3. **The specific methods and tools** they would use, by name.
4. **What would show the result is right**, other than Claude or the user: a
   test, a measurement, a primary source, a real user, an outside reviewer.

Question 4 matters most: name the check concretely (which test, which data,
what result counts as a pass), and say whether it can be run today. When the
task is about whether code or an algorithm is correct, the `verify` skill in
this plugin lists the methods.

Then rewrite the user's prompt to ask for exactly that, ending with the check
from question 4 and what counts as a pass, in its own fenced code block so it
can be copied. Stop there: do not run the rewritten prompt until the user
says so.
