---
name: verify
description: Check that an algorithm, tool or pipeline does what its author claims, with evidence from outside the model - property-based and differential tests, real data with a known answer, TLA+ for concurrency, Lean 4 proofs for core algorithms. Use when the user asks to verify that their code is correct, to look for bugs in an algorithm, or to model a pipeline.
---

# Verify

The goal is evidence that the code is right which does not rest on Claude
reading it and agreeing. Reading code finds candidates; only a check that
runs settles them.

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
    as Biopython, samtools, bcftools, BEDTools, SciPy or R's own functions, or
    a slow, obviously correct version written for the test.
  - *Metamorphic tests* when there is no oracle: a change to the input with a
    known effect on the output (reverse complement, shuffling read order,
    renaming contigs, scaling counts).
- **Numerics:** compare against a high-precision reference (mpmath), state
  the tolerance and why, and test zeros, NaN, infinities, underflow and very
  large values.
- **Concurrency, workflows, queues, retries, state machines** (a pipeline
  runner, a job scheduler, a service that consumes messages): model it in
  TLA+ (PlusCal is fine) and check it with TLC, or Apalache when the state
  space is too large. Model the failures too: crashes between two writes,
  messages delivered twice, parallel workers.
- **A small core algorithm worth a proof** (a dynamic-programming recurrence,
  an index invariant that everything else relies on): state the spec and
  prove it in Lean 4 with Mathlib. The proof covers the Lean model, not the
  Python, R or C++ code, so pair it with a differential test between the Lean
  version (`#eval`) and the real code.
- **Real data with a known answer:** a truth set or a published benchmark
  (for example Genome in a Bottle for variant calling), or a small dataset
  where the result was checked by hand.

Prefer the cheapest method that can fail. Property-based and differential
tests catch most bugs in a day; a TLA+ model or a Lean proof is worth it only
where the cost of a wrong answer is high or the bug would be rare and silent.

## 3. Rules

- A bug counts only when a test against the real code fails because of it.
  A model counterexample, a failed proof or a suspicious line without such a
  test is reported as "unconfirmed".
- Keep the failing inputs: shrink each to the smallest example and keep it as
  a regression test.
- Do not fix anything while checking unless the user asks. Report first.

## 4. Report

- Each claim, where it comes from, the method used and the result.
- How much was checked: number of generated cases, datasets, state-space
  size, or what the proof covers.
- Confirmed bugs, each with its failing test and the smallest input.
- Unconfirmed findings.
- What was not checked, and why.
