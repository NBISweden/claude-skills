# Contributing

Skills, hooks, agents, commands and small scripts that help NBIS staff
use Claude Code are welcome. To keep the repository useful rather than
full, every contribution has to meet the bar below.

## What belongs here

- It is **specific to NBIS** (our support work, our infrastructure, UU's
  rules) or something many of us repeat. A general-purpose skill that
  already exists in a public collection does not need a copy here.
- It does **one clear job**. Two small skills beat one that does
  everything.
- It contains **no secrets, no data and no internal hostnames or paths**.
  Use synthetic examples in evals.

## Where it goes

Contributions go into a plugin by topic, not by person:

| Plugin | For |
| --- | --- |
| `plugins/nbis` | General skills for working with Claude Code: prompts, verification, review |
| `plugins/nbis-safety` | Safe use of agents: setup, sandbox, secrets, data classification, hooks that block risky actions |

If your contribution fits neither, say so in the pull request and propose
a new plugin. A new plugin needs at least two related items and its own
owner; one skill on its own goes into an existing plugin.

A plugin looks like this:

```
plugins/<plugin>/
  .claude-plugin/plugin.json   name, version, description
  skills/<skill>/SKILL.md      one directory per skill, plus any files it uses
  hooks/hooks.json             hooks, if any, with their scripts in scripts/
  agents/<agent>.md            subagents, if any
  evals/<case>/                prompt.md, graders/*.md, optional case.yaml and files/
  tests/                       plain tests for scripts, run in CI
```

## What every contribution needs

1. **An owner.** Add yourself to `CODEOWNERS` for what you add. Owners
   review changes to their items and answer issues about them.
2. **At least one eval case** in the plugin's `evals/`, in the format
   `claude plugin eval` reads (see the existing cases). The graders should
   check what matters for the task, and the case should score better with
   the plugin than without it: `claude plugin eval` runs both by default.
3. **A test for every script** in the plugin's `tests/`, runnable with
   plain bash and no network.
4. **A version bump** in the plugin's `plugin.json` when anything in the
   plugin changes, so `/plugin marketplace update` picks it up. Patch for
   fixes, minor for new items.
5. **A line in the README** table for each new skill or hook.

## Rules for skills

- A skill that writes files, changes settings or runs commands on the
  user's behalf sets `disable-model-invocation: true`, so it only runs
  when the user calls it.
- Name it for what it does, in a word or two (`safe-setup`, `verify`).
- The `description` says when to use it and when not to.

## Rules for hooks

Hooks run on every tool call in every project where the plugin is on, so
they get a stricter review:

- Fast (well under a second), no network access, and no logging of the
  content they see.
- They only read, or block with a clear message. They do not change files.
- The README says exactly which events they run on and what they block.
- Put hooks in `nbis-safety` or a plugin of their own, never in `nbis`, so
  nobody gets a hook by installing a skill.

## Pull requests

CI runs on every pull request:

- `claude plugin validate --strict` on the marketplace and every plugin
- a structure check: every plugin has a lowercase-and-hyphens name, an
  owner, an eval case and a version bump when it changed
- a check that GitHub accepts every line in `CODEOWNERS` (no unknown users)
- `shellcheck` and the plugin's `tests/`
- `gitleaks` on the changes

The evals cost money, so they run only on pull requests with the
`run-evals` label (set by a maintainer), and only for the plugins that
changed, and a maintainer approves each run in the `evals` environment,
which holds the API key. In `nbis-safety` every grader must pass (`--threshold 1`): a safety check that
fails is a failed run, not a lower score. Other plugins need 0.8 per case,
since one LLM-judged run can miss a minor point by chance. Pull requests from a fork get no
repository secrets, so CI skips their evals; a maintainer runs them
locally, or pushes the reviewed branch to this repository and labels that
pull request. Run them locally before you ask:

```
claude plugin eval plugins/<plugin> --runs 1 --scaffold --allow-tools Bash Write Edit
```

When CI's pinned Claude Code version is raised, run the `safe-setup-enforced`
eval and the file-tool check in `plugins/nbis-safety/VERIFICATION.md` again,
and add a new dated record there.

## Removal

Items without an owner, or whose evals fail on `main` for more than a
month, are removed.
