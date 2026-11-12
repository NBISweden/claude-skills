---
name: hpc-cluster-safety
description: Safety and etiquette rules for working on a shared HPC cluster (login nodes, shared filesystems, job schedulers like SLURM/PBS), whether Claude reaches it over SSH or runs directly on a login node. Use whenever running commands on a cluster - running a bioinformatics tool, submitting or checking jobs, debugging a failed pipeline, searching for files, copying, transferring or deleting data, or any file/data work on a login node - or sizing memory and CPU requests in a job script or pipeline config for a cluster. Not for work that only runs on a laptop, workstation or other machine that only you use.
---

# HPC Cluster Safety

A login node and its shared filesystem (Lustre/GPFS/etc.) are multi-tenant.
Every rule below exists because the action degrades service for every other
user, not only your own session. Examples are SLURM; adapt them only once the
site's scheduler is known (§6). If the project's own rules (`AGENTS.md`) are
stricter than this skill, they win.

Write commands with long options (`--dry-run`, not `-n`) so the user can read
and review them; use a short option only when there is no long one.

If a rule says to ask and nobody can answer (the user is away, or the run is
headless), do only the steps that need no answer, stop, and list the open
questions. Do not substitute a default.

## 1. Run real compute through the scheduler

Login nodes are for file management, environment setup, light editing and job
submission.

- Anything that does real work (a tool on real data, multi-threaded processing,
  large copies or compression, more than a few seconds of CPU) goes through
  `srun`/`sbatch` (or the site's equivalent), not bare SSH execution.
- Cheap commands are fine directly: reading logs, `--version` checks,
  `squeue`/`sacct`, `cat`/`tail` on small files.
- If unsure which side of the line a command falls on, ask. "It should only
  take a few seconds" is not a judgment to trust.
- A pipeline's driver process (e.g. a Nextflow head job that only submits tasks)
  is often run in `screen`/`tmux` on a login node. Some sites forbid it. Check
  the site's policy first, and confirm the tool really only dispatches.
- Some sites bar AI agents from login nodes altogether (TACC: AI-assisted
  workloads on compute nodes only). If the site's policy says so, tell the user
  before doing anything else and work from an interactive compute allocation.

## 2. Scope every filesystem operation

On a parallel filesystem, a recursive scan hits the metadata servers that
everyone's I/O depends on.

- Never run `find`, `du`, `ls --recursive`, `grep --recursive` or similar over
  a broad path (`/`, a top-level project or scratch mount) or a very large
  directory. Search inside a known directory: the user's project path, or one
  the user gave. If you don't know the path, ask.
- Use plain `ls` for names. `ls --format=long` stats every file, so avoid it on
  large directories.
- Avoid wildcard globs over large directories; the shell enumerates them first.
- Inside a large project directory, prefer the filesystem-aware search (e.g.
  Lustre's `lfs find`). It makes a scoped search cheaper; it never licenses a
  broad one.
- Avoid creating many small files in one directory.

## 3. Throttle job-status polling

`squeue` queries the scheduler (slurmctld); `sacct` queries the accounting
database (slurmdbd). The SLURM docs warn against running either from loops.

- Poll no faster than about once a minute, less often for long jobs. Use
  `squeue` for live state and `sacct` for finished jobs.
- Run one polling loop at a time.
- Scope each query (`squeue --user=$USER`, `squeue --jobs=<id>`,
  `sacct --jobs=<id>`).
- Prefer `sbatch --parsable --wait` or the pipeline's own poller over a `sleep`
  loop. A long wait can outlast your tool's timeout: run it in the background,
  and never resubmit a job just because the wait timed out. Its exit code is not
  proof of success: check `State` with `sacct`. `--mail-type` only emails the
  user; it does not let you wait. If you use `watch`, keep it at
  `--interval=60` or slower and stop it when done.
- Submit many similar tasks as one job array with a concurrency cap
  (`--array=1-N%M`), not as a loop of `sbatch` calls.

## 4. Ask where scratch space is

Scratch means throwaway or intermediate files. Job scripts, logs and final
outputs belong in the project directory; no need to ask for those.

- On a login node or shared storage, ask for the project's scratch path before
  creating a scratch file, unless you already know it for this host this
  session. Do not default to `/tmp`: it is shared with other users on the node
  and is often small or node-local.
- Reuse the answer for the rest of the session on that host.
- Inside a job, use a job-local temp directory only if the site documents one
  (often `$TMPDIR`, or a private per-job `/tmp`). SLURM sets `TMPDIR=/tmp` when
  nothing else does and can inherit your shell's value, so a set variable proves
  nothing. If the site documents none, ask before submitting. The job script
  checks `df "$TMPDIR"`, fails loudly if `$TMPDIR` is `/tmp` and the site has not
  said that is private to the job, and copies results to project storage before
  the end. Job-local space may be small or memory-backed and disappears with the
  job.
- Cluster-specific paths belong in the project's own notes, not here.

## 5. Stay inside the project's directories

Do not read or list other users' or unrelated projects' paths, even read-only,
unless the user named the path or the site documents it as shared (reference
data, databases). If the task needs any other, say so and ask.

## 6. Ask when the site is unknown; don't assume SLURM

Submission syntax, partition names, accounting commands and filesystem type vary
by site. If a command fails because the tool is missing, ask about the site's
setup instead of trying nearby alternatives.

## 7. Check how memory and CPUs are allocated and billed

Two settings can make a job cost far more than it asked for, with no error.

- **Allocation.** If a job asks for more memory than the partition's
  `MaxMemPerCPU` allows for its CPUs (`--mem-per-cpu` above the limit, or `--mem`
  above CPUs times the limit), SLURM tries to raise the CPU count to fit (for
  `--mem-per-cpu` it multiplies `--cpus-per-task`): `--mem=120G` at
  `MaxMemPerCPU=4000` becomes 31 CPUs. This is best effort: the job may be
  rejected instead. `DefMemPerCPU` is only the default for a job that asks for
  no memory. Where the limit is
  `MaxMemPerNode`, an over-limit job is not widened: it is rejected at submit if
  `EnforcePartLimits` is `ALL` or `ANY`, and otherwise (the default) accepted and
  left pending. Do not wait on it.
- **Billing.** The partition's `TRESBillingWeights` set what each allocated unit
  costs. The total feeds fair-share priority and any billing limits, and is
  computed from what was allocated, not what was used.

The same applies however the job is submitted: `sbatch`/`srun`, or a
Nextflow/Snakemake resource config.

- Before a large or repeated job, read the limits: `scontrol show partition
  <name>` and `scontrol show config | grep MemPer`. A partition that prints
  `MaxMemPerNode=UNLIMITED` sets no limit of its own; the cluster-wide limit from
  `scontrol show config` still applies, if it is set. Size the request against
  them; do not pick a round "plenty" number. When trimming an oversized request,
  keep headroom above `MaxRSS`.
- After a run, compare request, allocation and use from accounting. Finished jobs
  leave `scontrol show job` after `MinJobAge` (300 s by default), and `sstat`
  only covers running ones:
  `sacct --jobs=<id> --format=JobID,State,ElapsedRaw,ReqMem,AllocCPUS,AllocTRES,TotalCPU,MaxRSS`.
  Read `MaxRSS` from the step rows (`.batch`, `.0`); `--allocations` omits steps
  and reports utilization as zero. CPU efficiency is
  `TotalCPU / (ElapsedRaw * AllocCPUS)`, with `TotalCPU` (`[DD-][HH:]MM:SS`)
  converted to seconds. If `sacct` returns nothing, accounting may be off; say
  so.
- An undersized request can be killed. Where SLURM detects it, `sacct` shows
  `OUT_OF_MEMORY` with `ExitCode 0:125`, and tools report 137 (SIGKILL). After
  such a kill `MaxRSS` understates the need (it is sampled), so raise the request
  above the failed one, not just above `MaxRSS`. If the memory need and the CPU
  ratio conflict, name a partition with a better ratio and ask before using it.

## 8. Dry-run before copying or deleting data

Find out what a transfer or deletion will touch before it touches anything. A
wrong directory or glob, or a secret or personal data in the file list, cannot
be undone once the data has left or is gone.

- Copying or syncing: use `rsync`, and run it first with `--dry-run` and
  `--itemize-changes`, with the same arguments, filters and trailing slashes as
  the real command. `--list-only` lists one level unless you add `--recursive`.
  `cp` and `scp` have no dry run.
- The dry run walks the whole source and destination, like the real run, so
  rules 1 and 2 apply to it: run it where the real run will run (§1), or on one
  sub-directory.
- Deleting: `rm` has no dry run. Expand the exact path or glob once
  (`ls --directory <glob>`, or a scoped `find <dir> -name '<pattern>' -print`,
  as in §2), read it, and delete only those names and only what the user asked
  to remove. `rm --recursive` also removes the contents of a directory it names,
  so list those too. `rsync --delete` and `--remove-source-files` need
  `--dry-run` first; the rsync manual calls `--delete` dangerous. Never copy
  from or delete a directory that a running job writes to.
- Read the list. Does it match the request, with nothing from outside the
  intended directory? In the itemized output, `*deleting` lines delete at the
  destination, `>f` lines without `+++++++++` overwrite existing files, and `cL`
  lines are symlinks. Does it hold secrets or personal data (`.env`, keys,
  `*.pem`, tokens, credentials, `.git`, `.ssh`), or data the user has classified
  as sensitive or not said may be copied? Is the destination inside this project,
  on storage approved for that data? Exclude what must not go (`--exclude`, or
  `--files-from` a list you checked) and dry-run again. Do not open the files to
  check. If unsure, stop and ask.
- `--archive` copies a symlink, not its target, so deleting the target leaves a
  broken link. Before deleting a source you copied, re-run the same copy with
  `--dry-run --checksum --itemize-changes`: an empty list means nothing is left
  to copy.
- Then run the same command without `--dry-run`. Any change to the options needs
  a new dry run.
- If nobody can answer, or the project's rules forbid running `rsync`, `scp`,
  `ssh` or deletions, do not run the transfer or the deletion, and do not run an
  `rsync` that contacts a remote host, dry run included. Give the user the
  `--dry-run` command and the real command. A local `ls --directory` or scoped
  `find` is fine.
- Large transfers and deletions go through the scheduler or the site's
  data-transfer node (§1).

## Sources

- [TACC Good Conduct Guide](https://docs.tacc.utexas.edu/basics/conduct/)
- [Login nodes vs. compute nodes - Iowa Biostat HPC](https://iowabiostat.github.io/hpc/4.html)
- [HPC Etiquette - University of Surrey](https://docs.pages.surrey.ac.uk/research_computing/gettingstarted/etiquette.html)
- [Lustre best practices - INCD](https://wiki.incd.pt/books/filesystem-user-guide/page/lustre-best-practices)
- [SLURM Best Practice Guide - NCC Spain](https://hpc-portal.eu/sites/default/files/content-document/ENG_BPG_SLURM_V3_NCC%20SPAIN%20.pdf)
