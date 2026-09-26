# 5-numerical-audit

> Historical numerical stage record. Active revised stage 5 is `5-unified.md`;
> remaining numerical/final audit work is tracked in `6-final-audit.md`.

## Current Facts

Quaternion, bank, and exact RGB stages are complete with actual axiom audits.
Finite probabilities, PMF and coefficient counts compile; final work-bound audit underway.
The proposal's numerical verification script, BF16 weights and execution trace remain
unavailable. No transformer or hardware experiment is part of this library.

## Updated Assumptions

BF16 facts concern ideal finite normal-value representation, defined explicitly by an
8-significant-bit integer mantissa and bounded power-of-two exponent. No arithmetic
rounding behavior is inferred. Later statistical/type extensions remain conditional.

## Big Picture Objective

Prove grid representability, preserve limitation counterexamples, independently check
the actual finished scope, and deliver a faithful map and full main-result axiom audit.

## Detailed Implementation Plan

Numerics/BFloat16 supplies a rational finite-grid certificate and real-value bridge;
diagnostic leaves establish zero residual/wrong target and a multi-input rank obstruction.
Document missing numerical trace, Gaussian assumptions, and deferred architecture claims.
Audit all exported major results and ensure no proof holes or custom axioms.

## Build Structure

Numerics and counterexample leaves are independent of probability/spectral consumers
except where their specific theorem requires the bank. Axiom diagnostics remain outside
the root. Focused leaf builds followed by root and explicit audit targets.

## Boundary Checks

Representation is not end-to-end recovery. Residual is not correctness/confidence.
No empirical performance theorem, invented numeric experiment, or generalization that
silently discards cross terms. Gaussian statistics require an explicit noise model.

## Completion Requirements

Main source claims map to actual statements or explicit excluded/deferred scope. Exact
representation facts and limitation examples compile. Pins, root, all audit targets,
source scans, documentation links, and whitespace checks pass with observed evidence.

## Stage Results

In progress.


## Revised-source update — 2026-09-26

This historical numerical work record now supports stage 6. Active stage 5 is
`5-unified.md`. Numerics/BFloat16 and Diagnostics/Limitations focused builds passed;
consolidated numerical/limitation axiom audit is still pending. Revised §9 precision
claims require the same exact-versus-floating-point distinction. The independent formal
counterexample is (0,0,16)→(0,0,17), not the unavailable source FP32 trace.
