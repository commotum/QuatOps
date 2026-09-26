# 6-integration

## Current Facts

Stages 1–5 have checked Lean implementations. The public API exports all
mathematical/architecture leaves and excludes diagnostics. The explicit audit
selects 102 main results. Pins remain Lean/mathlib v4.32.0 with locked dependency
revisions. Some scaffold-era documentation still describes obsolete open work.

## Updated Assumptions

The verified core covers source algebra, architecture, derivatives, corrected
initialization moments and conditional counts. Chi-density/law identification,
QLSTM gradients, empirical recognition/runtime, general loss/readout adapters,
and optimization/convergence are outside this core, explicitly recorded.
No outstanding required theorem can be hidden behind a green build.

## Big Picture Objective

Finish a reusable library with reproducible validation, an honest source/claim
map, correction records, and kernel axiom audit. Verify every explicit objective
against actual declarations and command results before marking the goal complete.

## Detailed Implementation Plan

Refresh README, dependencies, outline and plan to describe the final API and
assumptions. Provide a targeted cache/build/check command without importing all
mathlib or touching other paper folders. Rebuild project modules from clean local
artifacts while retaining the pinned mathlib cache, then explicitly compile all
diagnostic leaves. Audit axioms, proof holes, public import boundaries and pins.
Record the final completion table and exact command results.

## Build Structure

The public Qrnn entry point is a thin import-only API. Architecture/count and
initialization leaves remain independent of BPTT/calculus. Diagnostics
AxiomAudit/BPTTAudit/InitializationAudit and the dependency smoke leaf compile
explicitly, outside public imports. Clean only this project's .lake/build;
retain .lake/packages and local dependency cache. Final full build is justified.

## Boundary Checks

No sorry/admit/project axioms, unchecked proof execution, relaxed resource limits,
empirical theorem claims, broad global instances, or edits outside this folder.
Kernel-reported axiom dependencies must be a subset of propext, Classical.choice,
Quot.sound. Paper checksum, toolchain and manifest pins must match earlier records.

## Completion Requirements

Requirement table with actual module/declaration/command evidence; clean public
build; explicit smoke/diagnostic build; 102-result kernel audit; proof-hole and
import-boundary scans; git diff --check; honest excluded/unresolved source claims;
README/build instructions and current plan/map/outline. Only then mark complete.

## Stage Results

In progress: refresh final documents and execute clean project validation.
