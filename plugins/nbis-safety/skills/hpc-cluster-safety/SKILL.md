---
name: hpc-cluster-safety
description: Safety and etiquette rules for working on a shared HPC cluster (login nodes, shared filesystems, job schedulers like SLURM/PBS), whether Claude reaches it over SSH or runs directly on a login node. Use whenever running commands on a cluster - running a bioinformatics tool, submitting or checking jobs, debugging a failed pipeline, searching for files, or any file/data work on a login node - to avoid degrading a shared resource for other users. Not for a laptop, workstation or other machine that only you use.
---

# HPC Cluster Safety

A login node and its shared filesystem (Lustre/GPFS/etc.) are multi-tenant.
Every rule below exists because the action degrades service for every other
user, not only your own session.

If a rule says to ask and the user is away, do the safe part, leave the rest
undone, and report what is waiting on an answer. Do not guess.

## 1. Run real compute through the scheduler

Login nodes are for file management, environment setup, light editing and job
submission.

- Anything that does real work (a tool on real data, multi-threaded processing,
  more than a few seconds of CPU) goes through `srun`/`sbatch` (or the site's
  equivalent), not bare SSH execution.
- Cheap commands are fine directly: reading logs, `--version` checks,
  `squeue`/`sacct`, `cat`/`tail` on small files.
- If unsure which side of the line a command falls on, ask. "It should only
  take a few seconds" is not a judgment to trust.
- A pipeline's driver process (e.g. a Nextflow head job that only submits tasks)
  is often run in `screen`/`tmux` on a login node. Some sites forbid it. Check
  the site's policy first, and confirm the tool really only dispatches.

## 2. Scope every filesystem operation

On a parallel filesystem, a recursive scan hits the metadata servers that
everyone's I/O depends on.

- Never run `find`, `grep -r` or similar over a broad path (`/`, a top-level
  project or scratch mount). Search inside a known directory: the user's project
  path, or one the user gave. If you don't know the path, ask.
- Use plain `ls` for names. `ls -l` stats every file, so avoid it on large
  directories.
- Avoid wildcard globs over large directories; the shell enumerates them first.
- Inside a large project directory, prefer the filesystem-aware search (e.g.
  Lustre's `lfs find`). It makes a scoped search cheaper; it never licenses a
  broad one.
- Avoid creating many small files in one directory.

## 3. Throttle job-status polling

`squeue` queries the scheduler; `sacct` queries the accounting database, and the
SLURM docs warn against calling it in loops.

- Poll no faster than about once a minute, less often for long jobs.
- Run one polling loop at a time.
- Scope each query (`squeue -u $USER`, `squeue -j <id>`, `sacct -j <id>`).
- Prefer waiting on the scheduler (`sbatch --wait`, `--mail-type`) or the
  pipeline's own poller over a `sleep` loop. If you use `watch`, keep it at
  `-n 60` or slower and stop it when done.

## 4. Ask where scratch space is

Scratch means throwaway or intermediate files. Job scripts, logs and final
outputs belong in the project directory; no need to ask for those.

- On a login node or shared storage, ask for the project's scratch path before
  creating a scratch file, unless you already know it for this host this
  session. Do not default to `/tmp`: it is shared with other users on the node
  and is often small or node-local.
- Reuse the answer for the rest of the session on that host.
- Inside a job, use the site's job-local temp directory (usually `$TMPDIR`) only
  if it is set there. It is site-configured, may be small or memory-backed, and
  disappears with the job. Check `echo $TMPDIR` and `df`, and copy results to
  project storage before the job ends. If it is unset, ask.
- Cluster-specific paths belong in the project's own notes, not here.

## 5. Stay inside the project's directories

Do not read or list other users' or unrelated projects' paths, even read-only.
If the task needs one, say so and ask.

## 6. Ask when the site is unknown; don't assume SLURM

Submission syntax, partition names, accounting commands and filesystem type vary
by site. If a command fails because the tool is missing, ask about the site's
setup instead of trying nearby alternatives.

## 7. Check how memory and CPUs are allocated and billed

Two partition settings can make a job cost far more than it asked for, with no
error. SLURM examples; other schedulers have equivalents.

- **Allocation.** If a job requests more memory per CPU than `MaxMemPerCPU`,
  SLURM raises its CPU count to fit, whatever `--cpus-per-task` said. A large
  memory request for a single-threaded step can reserve many cores.
  `DefMemPerCPU` is only the default for a job that requests no memory.
- **Billing.** `TRESBillingWeights` set what each allocated unit costs. The total
  feeds fair-share priority. It is computed from what was allocated, not used,
  and does not change the allocation.

The same applies however the job is submitted: `sbatch`/`srun`, or a
Nextflow/Snakemake resource config.

- Before a large or repeated job, read the partition limits
  (`scontrol show partition <name>`, or `scontrol show config | grep MemPer` if
  the partition sets none) and size the request against them. Do not pick a
  round "plenty" number.
- After a run, compare request, allocation and use from accounting. Finished jobs
  disappear from `scontrol show job` and `sstat` only covers running ones:
  `sacct -j <id> -o JobID,State,Elapsed,ReqMem,AllocTRES,TotalCPU,MaxRSS`.
  Read `MaxRSS` from the step rows (`.batch`, `.0`); `-X` omits steps and
  reports utilization as zero. CPU efficiency is `TotalCPU / (Elapsed * AllocCPUS)`.
  If `sacct` returns nothing, accounting may be off; say so.
- When a request is multiplying cost, fix it, but never below the observed
  `MaxRSS` plus headroom: an undersized request is killed (exit 137, out of
  memory). If the memory need and the CPU ratio conflict, pick a partition with a
  better ratio or ask.

## Sources

- [TACC Good Conduct Guide](https://docs.tacc.utexas.edu/basics/conduct/)
- [Login nodes vs. compute nodes - Iowa Biostat HPC](https://iowabiostat.github.io/hpc/4.html)
- [HPC Etiquette - University of Surrey](https://docs.pages.surrey.ac.uk/research_computing/gettingstarted/etiquette.html)
- [Best practices on Lustre parallel file systems - ETH Zurich](https://scicomp.ethz.ch/wiki/Best_practices_on_Lustre_parallel_file_systems)
- [Lustre best practices - INCD](https://wiki.incd.pt/books/filesystem-user-guide/page/lustre-best-practices)
- [slurm.conf: DefMemPerCPU, MaxMemPerCPU - SchedMD](https://slurm.schedmd.com/slurm.conf.html)
- [Trackable resources and TRESBillingWeights - SchedMD](https://slurm.schedmd.com/tres.html)
- [sbatch - SchedMD](https://slurm.schedmd.com/sbatch.html)
- [sacct - SchedMD](https://slurm.schedmd.com/sacct.html)
- [SLURM Best Practice Guide - NCC Spain](https://hpc-portal.eu/sites/default/files/content-document/ENG_BPG_SLURM_V3_NCC%20SPAIN%20.pdf)
