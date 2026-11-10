---
name: practice
description: Create a small practice project with made-up data for a first session with Claude Code and the NBIS safe setup - a failing test to fix, a data folder that is kept out of reach, an install that asks. Use it to learn; not for real projects or data. Invoked explicitly with /nbis-safety:practice; writes one new folder and nothing else.
disable-model-invocation: true
---

# Practice project

Create a ten-minute practice project for someone trying Claude Code for
the first time. Everything in it is made up. Answer in the user's
language. The files to copy sit in `files/` next to this SKILL.md.

1. **Ask where** to create the folder (default `./nbis-agent-practice`).
   If that folder already exists, stop and ask what to do: never write
   into it or overwrite it.
2. **Write the five files** with the Write tool, each at the same path
   under the new folder as under `files/`: `README.md`, `src/qc.py`,
   `data/sample1.fastq`, `tests/test_qc.py` and `tests/fixture.fastq`.
   Read each one from `files/` and write it unchanged. `src/qc.py` has a
   planted bug: keep it. Do not run the test, fix the bug or run
   safe-setup yourself; the user does that in the exercises.
3. **Tell the user the next steps:** quit this session, `cd` into the new
   folder, start Claude Code there and run `/nbis-safety:safe-setup`
   (support work, K1, data in `./data`). Then start a new session in the
   folder for the exercises.
4. **Give the three exercises** to type in that new session, each with
   what they should see:
   - "Fix the failing test in tests/test_qc.py": the agent changes
     `src/qc.py`, and `python3 tests/test_qc.py` prints `test_qc: ok`.
   - "Show me the first lines of data/sample1.fastq": refused. The
     sandbox and the deny rules keep the agent out of `./data`, as they
     would with a researcher's data.
   - "Install the package requests with pip": Claude Code asks you first
     (or the agent gives you the command to run yourself). Say no.

   Then the check from safe-setup's last step: ask Claude to run
   `bash .nbis-safety/check.sh --verify`.
5. **Close:** nothing here is real, so a mistake costs nothing. Delete the
   folder when done. Questions go to `#claude-code` on NBIS Slack.

Report the folder and the files written.
