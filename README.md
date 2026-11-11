# claude-skills

Plugins for [Claude Code](https://code.claude.com) from NBIS. Each plugin is
installed on its own, so you only get what you choose.

| Plugin | Contents |
| --- | --- |
| `nbis` | General skills: `deeper` and `verify` |
| `nbis-safety` | Safe use of AI coding agents: `safe-setup` and `practice` |

| Skill | What it does |
| --- | --- |
| `/nbis:deeper` | Turns a task into a deeper version of itself, not a bigger one: what a top professional would do, the raw material they would start from, their methods and tools, and what would show the result is right. Then rewrites your prompt. Runs only when you call it. |
| `/nbis:verify` | Checks that an algorithm, tool or pipeline does what you claim: property-based and differential tests, workflow and stochastic tests, real data with a known answer, TLA+ for concurrency, Lean 4 for a core algorithm. A bug counts only when a test against the real code fails. |
| `/nbis-safety:safe-setup` | Checks a project and sets up Claude Code for it the NBIS way: sandbox on, home and data directories out of reach, deny rules for secrets, and an `AGENTS.md` for a researcher's project or for NBIS's own open code. Stops for K3 data. Shows everything and writes only when you say yes. Runs only when you call it. |
| `/nbis-safety:practice` | Creates a small practice project with made-up data for a first session: a failing test to fix, a data folder that safe-setup keeps out of reach, and an install that asks you. Writes one new folder, never into an existing one. Runs only when you call it. |

## Install

In Claude Code:

```
/plugin marketplace add NBISweden/claude-skills
/plugin install nbis@nbisweden
/plugin install nbis-safety@nbisweden
```

In Claude Desktop (Code tab) and the VS Code extension, the same commands
open a plugins window instead: add `NBISweden/claude-skills` under
**Marketplaces**, then install `nbis` and `nbis-safety` under **Plugins**,
for you (user scope).

The terminal, Claude Desktop and the VS Code extension on one computer read
the same settings, so a plugin installed for you in one of them is there in
the others too.

Run `/plugin marketplace update nbisweden` to fetch new versions, then
`/reload-plugins` or start a new session to use them.

## Usage

```
/nbis:deeper benchmark my read trimmer against fastp
/nbis:verify my k-mer counter in src/kmers.py
/nbis-safety:safe-setup
```

## Example

A quick, sloppy first prompt:

```
/nbis:deeper can u check my kmer counter works? want to use it for genome size estimate on our new beetle assembly
```

`deeper` first points out what the prompt misses: a genome size comes from
the k-mer histogram of the raw reads, not the assembly; the counter should be
checked against Jellyfish bin by bin; and the real test is a simulated genome
of known size. Then it rewrites the prompt, ending with what counts as a pass.
It stops there and runs nothing.

Review the rewritten prompt before you run it: it is a starting point, not an
answer. In this one, for example, GenomeScope2 assumes a diploid genome by
default (`-p 2`), so the prompt should say what ploidy the simulated genome
has, or the 2 % check can fail for reasons that have nothing to do with the
counter.

<details>
<summary>The four questions</summary>

**1. What a top professional would do.** They would check the whole chain from reads to genome size, not only that the counter counts. A genome size estimate comes from the k-mer histogram of the raw reads, not from the assembly, so they'd confirm which input you plan to feed it. They'd check canonical k-mer handling (k-mer and reverse complement counted as one), handling of `N` and lowercase bases, k-mer overflow at high counts, and memory behaviour at beetle scale. They'd also separate two questions: does the counter give the right histogram, and does the histogram give the right size once error and heterozygous peaks are handled? Beetle genomes are repeat-rich and often heterozygous, which skews naive "total k-mers ÷ peak" estimates.

**2. Rawest material.** Your counter's source and its CLI as it exists on disk. A real read subset from the beetle (a few million reads of the actual FASTQ), not the assembly and not a summary. A simulated genome with a known size to test against.

**3. Methods and tools.**
- Jellyfish or KMC as the reference counter, run with the same k and canonical mode (`jellyfish count -C -m K`, `jellyfish histo`).
- A differential test of your histogram against theirs.
- Hypothesis property tests: reverse-complement invariance, the sum of count×frequency equal to the number of k-mer positions, and read order not mattering.
- `wgsim` or `art_illumina` on a random genome of known size, at several coverages, with an error rate.
- GenomeScope2 on the histogram for the final estimate, plus `smudgeplot` if ploidy or heterozygosity is in doubt.

**4. What shows it's right.** This can run today if the counter's code is reachable; Jellyfish and the simulators are installable.
- **Exact check:** on a small real-read subset, your histogram must match Jellyfish's exactly, with every count bin equal. Any difference is a bug.
- **Known-answer check:** simulate a 50 Mb genome at 30x with 1% errors. Your counts fed into GenomeScope2 must give a size within 2% of 50 Mb.
- **Outside check:** the final beetle estimate should agree with Jellyfish plus GenomeScope2 on the same reads, and be plausible against the assembly size and the Animal Genome Size Database value for the family.

</details>

<details>
<summary>The rewritten prompt</summary>

```
Verify that my k-mer counter is correct and fit to estimate genome size for our new beetle assembly. Work in three stages and report evidence for each.

Context: the genome size must be estimated from the raw sequencing reads' k-mer histogram, not from the assembly. First locate my k-mer counter (ask me for the path if you cannot find it), read its source, and state its inputs, k, and whether it counts canonical k-mers. Ask me for the beetle read files and the k I intend to use; until then use a few-million-read subset.

Stage 1, correctness against a reference. Install Jellyfish (or KMC) and run it with the same k and canonical mode on a small real-read subset. Compare the full count histogram from my counter with `jellyfish histo` bin by bin. Report every differing bin, trace each to a cause in my code, and fix nothing without telling me first.

Stage 2, property tests. Write Hypothesis tests for: a read and its reverse complement give identical histograms; sum of count x frequency equals the number of k-mer positions in the reads; read order does not change the result; behaviour on N, lowercase, reads shorter than k, and counts above any fixed-width limit. Report which pass or fail.

Stage 3, known-answer genome size. Simulate a random 50 Mb genome with wgsim or art_illumina at 10x, 20x and 30x with a 1% error rate. Run my counter, then GenomeScope2 on its histogram. Also run Jellyfish plus GenomeScope2 on the same reads as an outside reference. Then check memory and runtime scaling toward a beetle genome of roughly 0.2 to 2 Gb.

Finally, if the beetle reads are available, run the real estimate and compare it with the assembly size and with the Animal Genome Size Database value for the family. Note heterozygosity and repeat content from the GenomeScope2 fit.

Pass criteria: the histogram is identical to Jellyfish's on the real-read subset; all property tests pass; the simulated genome size is recovered within 2% at 20x and 30x with my counter; and my counter's final estimate agrees with the Jellyfish plus GenomeScope2 estimate within 2%. Report any failed check with its output. Do not report the counter as working if any check did not run, and say why.
```

</details>

## Safe setup

Run `/nbis-safety:safe-setup` in the project folder. It runs a read-only check
(`plugins/nbis-safety/skills/safe-setup/check.sh`: Claude Code version, sandbox dependencies,
toolchain paths, existing sandbox settings that would weaken the setup,
secret-like and data files, MCP servers, gitleaks), asks
whether the folder holds anything that belongs to someone else
(a researcher's data, results or code), the data's UU confidentiality
class and where the data is, and then proposes:

- `.claude/settings.json`: what Claude Code **enforces**. The sandbox is on
  and a failed command is not retried outside it; shell commands
  cannot read your home directory (apart from your toolchain) or the data
  directories; Claude's own file tools are denied the data and secrets; the
  network is limited to package registries, and any other host needs your
  approval, or in auto mode the classifier's. For a hard block, the skill
  offers `strictAllowlist` in your `~/.claude/settings.json`, together with
  the registry list (with it on, a project's own list is ignored), the only place
  Claude Code reads it (not verified: that hosts on the project's list
  still connect with it on).
- `AGENTS.md` plus `@AGENTS.md` in `CLAUDE.md`: **instructions** that
  Copilot, Codex, Cursor and Gemini read too. They guide the agent but are
  not a boundary.

It sets up one project folder at a time. For the whole computer it only
offers, each on a separate yes, `strictAllowlist` with `classifyAllShell`,
and a baseline that keeps
Claude's file tools away from keys and `.env` files in every folder (shell
commands only where the sandbox is on). Which directories
hold data, which hosts the agent needs and whose material it is
differ between projects, and settings in `~/.claude/settings.json` apply to
all of them. Run it once in each project you use an agent in.

This setup makes working with an agent safer. It does not make it safe:
you still decide what the agent may reach, and you still read what it does.

**Auto mode.** Claude Code starts in auto mode. Before each command runs,
a classifier checks it and blocks risky ones you might approve without
reading, such as sending data out or deleting files. Treat it as a second
check, not a boundary: the sandbox and the deny rules are what actually
protect you.

**Package installs.** Claude asks you before installing packages with
`pip`, `uv`, `conda`, `mamba` or `npm`, or with R's `install.packages` or
`BiocManager::install` (run through `Rscript -e` or `R -e`). An install
started some other way may not ask.

The setup depends on whose material is in the folder, not on what you do
there. **A researcher's project** (their data, unpublished results or
code, which is most support work, including when you write code in it)
gets the stricter version: every command goes through the
classifier (with `classifyAllShell`, which the skill offers; without it, a
command that matches one of your own allow rules skips the classifier, as
tested with Claude Code 2.1.322 on Ubuntu 26.04) or asks you, in manual
mode; a push asks you, Claude's memory is off, and the agent adds no dependencies or MCP servers. In **NBIS's
own open code**, with no researcher's data, sandboxed commands run without
asking. If it is unclear or mixed, use the stricter one. To approve every command
yourself while you learn what the agent does, press Shift+Tab for manual
mode.

With the sandbox on, `ssh`, `rsync` and `git push` to servers don't work
from inside Claude Code: run them yourself, or with `!` at the prompt.
On Windows the sandbox needs WSL2: set up and open the project in WSL,
since a project set up there will not start from native Windows. To undo
the setup, see [Undo](plugins/nbis-safety/skills/safe-setup/SKILL.md#undo):
the skill's report lists each file and line it added.
Background: NBIS's gateway page on AI coding agents and the technical guide
under it, on Confluence.

To check the setup at any time, ask Claude to run `check.sh --verify` in a
session in the project: it prints one line per protection, *configured*,
*tested* (a live attempt was refused) or *not tested*, using a harmless
test file the skill places in a blocked folder. safe-setup puts a copy of the check in the project, so the command is
`bash .nbis-safety/check.sh --verify`. A read counts as *tested: blocked*
only when the sandbox visibly hides the test folder; anything less clear
is *not tested*.

Tested with Claude Code 2.1.318 on Ubuntu 26.04 (CLI) and macOS 27.0.1 (CLI,
VS Code extension and Claude Desktop): shell commands inside the sandbox
could not read `~/.ssh`, the data directory or `.env`. What has been
verified since, on which version and platform, and what has not, is in
[VERIFICATION.md](plugins/nbis-safety/VERIFICATION.md). Not verified there
so far: the `pip`, `uv`, `conda`,
`mamba`, `npm` and push `ask` rules, memory off, a failed command not being
retried outside the sandbox, `ssh` and `rsync` failing inside it, and the
Windows/WSL2 note.

## Contributing

Skills, hooks, agents and other helpers are welcome. Read
[CONTRIBUTING.md](CONTRIBUTING.md) first: it says which plugin a
contribution belongs in, what it needs (an owner and an eval), and how pull
requests are checked.

## License

MIT
