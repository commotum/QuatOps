# 3-bptt

## Current Facts

Stages 1–2 compile. Generic BPTT, actual QRNN joint differentiability, finite-run
sensitivity, reverse pullback, and terminal hidden-state loss derivatives compile.
Explicit accumulated parameter gradients and a variable output head remain open.
Before this refactor BPTT imported the complete quaternion loss stack and the
public entry point imported diagnostic axiom printing. The baseline standalone
BPTT check took 4.30 s, peak RSS 2967744 KiB (one warm-cache measurement).

## Updated Assumptions

Preserve all existing declaration names, definitions, theorem statements, and
proof bodies while changing dependency ownership. Ordinary real calculus and
fixed initial states remain the mathematical conventions. Timings are local
observations, not portable speedup guarantees.

## Big Picture Objective

Complete correct QBPTT and all parameter gradients. Apply the user's
`implementations/BUILD-PLAN.md` guidance before extending this stage, so generic
BPTT and architecture definitions have smaller incremental build dependencies.

## Detailed Implementation Plan

Current continuation target: add the narrow leaf `Qrnn/QRNNGradients.lean`.
First evaluate the actual joint Jacobian on parameter/state directions using
uniqueness of the proved real derivative. Then identify the partial maps,
reconstruct quaternion gradient accumulation, and verify the variable output-head
terminal and summed losses. Keep the existing high-fanout modules stable;
focused command: `lake build Qrnn.QRNNGradients`. Add public/audit imports only
once the leaf's results compile.


Remove diagnostics from the public entry point. Import only the calculus modules
used by generic BPTT; let its quaternion consumer import Loss explicitly.
Move existing split activation definitions into ActivationCore, leaving calculus
in Activation; Forward imports the former and Derivatives imports both layers.
Remove unused heavy imports when focused builds confirm they are unnecessary.
Then resume explicit accumulated gradients and the variable output-head loss.

## Build Structure

ActivationCore owns public componentwise activation definitions and one existing
coordinate lemma. Activation owns calculus proofs. Forward owns architecture
and real-expansion proofs. BPTT owns quaternion-independent proof-side calculus;
QRNNBPTT owns the concrete bridge. AxiomAudit remains a diagnostic leaf.
Algebra's public surface is unchanged. Build each changed layer, then its
adjacent consumers. A full `lake build` is justified by the public import change.

## Boundary Checks

No weakened theorem statements, deleted proofs, new project axioms, proof holes,
global instances, raised resource limits, or unchecked automation shortcuts.
Inspect declaration relocation and kernel axiom output. Public API must not
import diagnostics. All files and logs remain inside this QRNN folder.

## Completion Requirements

Build-time subtask: focused builds, full API build, explicit axiom audit,
proof-hole scan, `git diff --check`, measured check results and documentation.
Mathematical stage: all four accumulated parameter families for actual QRNN
terminal/summed losses, including a variable output head, with source corrections.
The build-time subtask does not complete the mathematical stage or full goal.

## Stage Results

Build-time subtask completed on 2026-09-25:
- Generic BPTT imports FDeriv.Add and FDeriv.Prod, with no quaternion dependency.
  QRNNBPTT explicitly imports Loss. Focused BPTT build passed (1933 tasks versus
  the prior quaternion closure); task totals include cached dependencies.
- ActivationCore contains the unchanged splitActivation, splitReal,
  vectorActivation, and components_splitActivation declarations. Forward imports
  this layer; Derivatives explicitly imports Activation. Activation no longer
  imports the unused Normed.Module.FiniteDimension module.
- Qrnn no longer imports diagnostic AxiomAudit. The audit is an explicit leaf
  check, so changing audit declarations does not rebuild the public library.
- Focused builds passed: ActivationCore/Activation/Forward, then
  Derivatives/Loss/QRNNBPTT. Full public API build passed (2436 tasks).
- Independent warm-cache BPTT check: 4.01 s, peak RSS 2554528 KiB versus baseline
  4.30 s, 2967744 KiB; roughly 14% less peak memory. These are individual local
  observations, not a benchmark guarantee. Unchanged public build: 2.22 s.
  Actual post-change measurements are in build-times.txt.
- Explicit AxiomAudit check passed; all 35 reported results depend only on
  propext, Classical.choice, Quot.sound. No proof holes/project axioms found.
- Whitespace and import-boundary checks passed. Existing theorem names,
  statements, and proof bodies are retained; only dependency ownership changed.

Mathematical stage remains in progress. Next establish explicit accumulated
parameter gradients with a variable output head and terminal/summed losses.
