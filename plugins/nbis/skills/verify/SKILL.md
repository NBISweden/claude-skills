---
name: verify
description: Check that an algorithm, tool or pipeline is correct using executable evidence - property-based and differential tests, real data with a known answer, TLA+ for concurrency, Lean 4 proofs for core algorithms. Use whenever the user asks to look for bugs in code, whether code is correct, or whether it behaves like a reference tool, before answering from reading the code alone. Not for workflow design or documentation.
---

# Verify

The goal is evidence that the code is right which does not rest on Claude
reading it and agreeing. Reading code finds candidates; only a check that
runs on the real code settles them, and only when its expected values come
from outside the model: a paper, a trusted tool, a hand-checked example. A
reference the model wrote for the test can share the bug, so agreement with
it alone proves nothing.

## 1. Write down the claim

Before choosing a method, state what the code is supposed to do as checkable
properties, and cite where each comes from: the paper, the spec, the
docstring, the author's own words. Examples: "the score equals the optimal
global alignment score under this scoring matrix", "counts are identical for
a read and its reverse complement", "a sample never reaches `done` without
passing QC". A property nobody can cite is a guess; say so.

## 2. Pick the method that fits the code

- **A function with a clear spec** (alignment, k-mer counting, interval
  overlap, variant normalisation, a statistic):
  - *Property-based tests* that generate thousands of inputs, including the
    edge cases (empty, length 1, all `N`, very long, duplicates): Hypothesis
    (Python), proptest (Rust), RapidCheck (C++), hedgehog (R),
    Supposition.jl (Julia).
  - *Differential tests* against a trusted reference on the same inputs, such
    as Biopython, samtools, bcftools, BEDTools, SciPy or R's own functions.
    Match versions, parameters and semantics first: 0- or 1-based
    coordinates, strand, missing values, scoring and tie handling.
  - *Metamorphic tests* when there is no oracle: a change to the input with a
    known effect on the output (reverse complement, shuffling read order,
    renaming contigs, scaling counts).
- **Workflows** (Nextflow, Snakemake) and **R packages:** run small
  end-to-end tests whose expected outputs and sample identities were checked
  independently, with nf-test or pytest; for R, testthat and `R CMD check`.
  Snapshot tests generated from a previous run only show that nothing
  changed, not that it was right.
- **Stochastic algorithms** (MCMC, sampling, simulation): one seeded run
  proves nothing. Test across many seeds against a known distribution, with
  an acceptance limit you can justify; record the RNG, seeds and versions.
- **Numerics:** compare against a higher-precision reference (mpmath with
  `mp.dps` raised until the result stops changing), justify the tolerance,
  and test zeros, NaN, infinities, underflow and very large values. Agreeing
  within tolerance is not the same as bit-identical across machines.
- **Concurrency, queues, retries, state machines** (a job scheduler, a
  service that consumes messages): model it in TLA+ (PlusCal is fine) and
  check it with TLC, or Apalache for symbolic checking. Model the failures
  too: crashes between two writes, messages delivered twice, parallel
  workers. Apalache checks only a bounded number of steps (10 by default):
  report the bound, the constants and how each model step maps to the code.
- **A small core algorithm worth a proof** (a dynamic-programming recurrence,
  an index invariant that everything else relies on): prove it in Lean 4 with
  Mathlib. Run `#print axioms` on the theorem and reject `sorryAx`, and check
  that the theorem states the original claim. The proof covers the Lean
  model, not the real code, so also compare the Lean version (`#eval`) with
  the real code on the same inputs.
- **Real data with a known answer:** a truth set or published benchmark, or
  a small dataset checked by hand. Pin the sample, benchmark release,
  reference FASTA and annotation versions; for Genome in a Bottle, use the
  matching benchmark VCF together with its confident-region BED.

Prefer the cheapest method that can fail. Use TLA+ or Lean only where a
wrong answer is costly or the bug would be rare and silent.

## 3. Rules

- A bug counts only when a test against the real code fails because of it.
  A model counterexample, a failed proof or a suspicious line without such a
  test is reported as "unconfirmed".
- Keep the failing inputs: shrink each to the smallest example and keep it as
  a regression test.
- Do not fix anything while checking unless the user asks. Report first.

## 4. Report

- Each claim, where it comes from, the method used and the result.
- The commands run, their inputs and their actual output, so anyone can
  repeat them.
  If the tests could not be saved to a file, put the exact commands or
  script in the reply.
- How much was checked: generated cases, datasets, model bounds, or what the
  proof covers. A pass supports only that claim on that domain.
- Confirmed bugs, each with its failing test and the smallest input.
- Unconfirmed findings.
- What was not checked, and why.
