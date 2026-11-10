---
name: hpc-cluster-safety
description: Safety and etiquette rules for working on a shared HPC cluster over SSH (login nodes, shared filesystems, job schedulers like SLURM/PBS). Use whenever running commands on a remote HPC cluster - checking pipeline/job status, debugging a failure, or doing any file/data work on a login node - to avoid degrading a shared resource for other users. Not for local/single-tenant machines.
---

# HPC Cluster Safety

A cluster login node and its shared filesystem (Lustre/GPFS/etc.) are **multi-tenant
shared resources**. Every rule here exists because the underlying action degrades
service for every other user on the system, not just your own session - treat that
as the standing justification, not each individual rule.

## 1. Never run real compute on a login node

Login nodes exist for file management, environment setup, light editing, and job
submission - not for running the actual workload. If the login node is
overburdened, nobody can submit or manage jobs.

- Anything that does real work - running a tool against real data, multi-threaded
  processing, anything that could run more than a few seconds of CPU - goes through
  the scheduler (`srun`/`sbatch` for SLURM; the equivalent for PBS/SGE/LSF), never
  bare SSH execution.
- Quick, cheap operations are fine directly on the login node: reading logs,
  `--version` checks, `sacct`/`squeue`, `cat`/`tail` on small files.
- If you're not sure which side of that line something falls on, ask rather than
  guess - "this should only take a few seconds" is not a safe-to-guess judgment
  call, it's exactly the kind of thing that turns out to be wrong.
- A pipeline's own driver process (e.g. a Nextflow head process that only submits
  jobs to the scheduler) is normally fine to run on a login node inside `screen`/
  `tmux` - it isn't doing the compute itself, it's dispatching it. Confirm that's
  actually true of the specific tool before assuming it.

## 2. Scope every filesystem operation - never scan cluster-wide

A recursive scan or metadata-heavy operation over an unscoped path doesn't just
take a while - on a parallel filesystem (Lustre/GPFS) it hammers the metadata
server(s) that every other user's I/O also depends on.

- Never run `find`, `grep -r`, or similar over a broad or unscoped path (`/`,
  a top-level shared project/scratch mount). Confine every search to a specific,
  already-known directory - the user's own project path, or one the user just gave.
  If you don't know the right path, ask; don't widen the search to compensate.
- Avoid `ls -l`/`ls -la` on directories with many entries - use plain `ls` if a
  filename listing is all you need. `-l` forces a stat() per file (touching every
  data server a striped file lives on), while a bare listing is metadata-only.
- Avoid wildcard globs over large directories for the same reason - shell
  expansion has to enumerate the whole directory first.
- If a site provides a filesystem-aware alternative (e.g. Lustre's `lfs find`),
  prefer it over generic `find` when doing anything broader than a single
  known subdirectory.
- Don't create large numbers of small files in one directory if avoidable -
  this is a known way to put a parallel filesystem's metadata server under load
  hard enough to affect the whole system, not just your own jobs.

## 3. Throttle any job-status polling

`squeue`/`sacct`/equivalent hit the scheduler itself, which is also a shared
resource - frequent polling degrades it for everyone submitting jobs, not just
your own queries.

- Never poll job status faster than about once a minute, and prefer sparser
  intervals for anything long-running - checking a multi-hour job every 30
  seconds has no benefit over checking every few minutes.
- Never run multiple concurrent polling loops against the same scheduler command.
- Prefer a single `sacct`/`squeue` call per check over `watch <cmd>` when
  scripting; if `watch` is genuinely needed interactively, keep the refresh
  interval at 60s or slower and stop it once you're done.

## 4. Ask where scratch/temp space is - never default to `/tmp` or guess

A cluster's `/tmp` on a shared login node is not the private, sandboxed `/tmp` of
a single-user machine - other users on the same node can potentially see it, and
it's often small, quota-limited, or node-local (silently gone if a job or session
lands on a different node next time).

- Before creating any temporary file on a cluster, ask the user for the project's
  designated scratch/temp path if you don't already know it for that host this
  session - don't default to `/tmp`, don't guess at a plausible-looking path.
- Once you have the answer for a given host in a session, reuse it for the rest
  of that session on that host rather than asking again for every file.
- Project-specific scratch paths (exact directories, env vars like a site's
  scratch-space variable) belong in that project's own memory/notes once
  established - this skill only covers the general rule to ask, not any
  particular cluster's actual path.

## 5. Stay inside the project's own directories

Don't read, list, or otherwise wander into other users' or unrelated projects'
paths on shared storage, even read-only and even out of debugging curiosity.
If something requires looking outside the current project's known paths, say so
and ask, rather than broadening scope on your own judgment.

## 6. When the scheduler or site conventions are unknown, ask - don't assume SLURM

Not every cluster uses SLURM. Job submission syntax, partition/queue names,
accounting commands, and shared-filesystem type all vary by site. If a command
fails because a tool/convention doesn't match what's actually installed, treat
that as a signal to ask about the site's actual setup rather than trying nearby
alternatives blind.

## 7. Check the scheduler's resource-to-billing ratio before requesting memory/CPUs

Many schedulers silently round a job's *allocated* (and billed) resources up from
what you asked for, based on a fixed ratio between one resource and another (e.g.
SLURM's `DefMemPerCPU`/`MaxMemPerCPU` forces CPU allocation to scale with requested
memory, regardless of `--cpus-per-task`). Requesting far more of one resource than
the job actually needs can silently multiply the billed cost many times over and
starve the account's scheduling priority - without ever producing an error, since
the job still runs fine on the oversized allocation it was never asked for.

This applies however the job gets submitted - a raw `sbatch`/`srun` script, a
Nextflow/Snakemake/other pipeline's process-resource config, or any other
submission mechanism - the scheduler applies the same ratio regardless of what
submitted the job.

- Before requesting memory (or any resource with a known conversion ratio) for a
  job that will run many times or at scale, check the partition's actual ratio
  (e.g. `scontrol show partition <name>` for `DefMemPerCPU`/`MaxMemPerCPU` on
  SLURM) and size the request against it, not just against "enough headroom."
- After a job runs at least once, verify what was actually allocated and used
  against what was requested (e.g. SLURM's `scontrol show job` for
  `ReqTRES` vs. `AllocTRES`, `sacct`/`sstat` for `MaxRSS`/`AveCPU` vs. requested
  memory/CPUs) - a large gap between requested and allocated, or between
  allocated and actually used, means the request is miscalibrated, not just
  generous.
- Don't default to a conservative-sounding round number (e.g. "80GB should be
  plenty") without checking what that number actually costs on this specific
  partition - the same request can be cheap on one partition and drastically
  over-billed on another depending on its ratio.
- If you find a job's resource request is multiplying its billed cost well above
  what it needs, flag it and fix the request - this is a correctness issue (wasted
  shared-allocation budget, degraded fairshare priority for the account), not
  just an optimization.

## See also

Project-specific cluster details (which host, jump-host chains, exact scratch
paths, pipeline-specific run scripts) belong in that project's own memory, not
here - this skill is the portable, cluster-agnostic half of that knowledge.

## Sources

- [TACC Good Conduct Guide](https://docs.tacc.utexas.edu/basics/conduct/)
- [Login nodes vs. compute nodes - Iowa Biostat HPC](https://iowabiostat.github.io/hpc/4.html)
- [HPC Etiquette - University of Surrey](https://docs.pages.surrey.ac.uk/research_computing/gettingstarted/etiquette.html)
- [Best practices on Lustre parallel file systems - ETH Zurich](https://scicomp.ethz.ch/wiki/Best_practices_on_Lustre_parallel_file_systems)
- [Lustre best practices - INCD](https://wiki.incd.pt/books/filesystem-user-guide/page/lustre-best-practices)
- [SLURM Best Practice Guide - NCC Spain](https://hpc-portal.eu/sites/default/files/content-document/ENG_BPG_SLURM_V3_NCC%20SPAIN%20.pdf)
