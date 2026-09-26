# 3-grid

**Current status:** revised ties-to-even decoding complete. The body through
Stage Results records the original half-down implementation; the revised requirements
are at the end. Its historical completion does not complete revised stage 3.

## Current Facts

Quaternion and bank leaves compile, including exact matrix Gram, fused inverse,
least-squares decomposition, error bounds, rank and spectral/operator-norm results.
The source's exact channel grid has 256 points at spacing 1/128.

## Updated Assumptions

Channels are Fin 256; RGB is Fin 3 → Channel. Exact real arithmetic is used.
Ties go to the smaller channel index; clipping is part of the bounded nearest-grid
specification. Strict half-spacing is required for guaranteed target recovery.

## Big Picture Objective

Prove the exact grid, channelwise nearest selection, clipping/rounding characterization,
global RGB least-squares optimality and perturbation-margin recovery.

## Detailed Implementation Plan

RGB/Core owns the algebraic grid without bank imports. RGB/Grid owns Euclidean
coordinates and spacing. RGB/Nearest owns finite tie-aware selection; RGB/Decoding
connects the grid optimum to the bank reconstruction theorem.

## Build Structure

Build each new leaf directly. Core/Grid do not import quaternion/bank spectral modules.
Only Decoding consumes Bank/LeastSquares. Promote finished modules through the root.

## Boundary Checks

No all-color exhaustive search in proofs, no unsupported floating-point guarantees,
no tie uniqueness assertion, no implicit maximum-norm/Euclidean-norm substitution.

## Completion Requirements

Grid injectivity/cardinality/spacing, specified ties/clipping, recovery and global
optimality compile, with actual axiom audit and declaration map updated.

## Stage Results

Complete. RGB Core/Grid/Nearest/Rounding/Decoding, GridAxioms and the public root
compile. Combined grid-audit/root build passed (2731 jobs). Twelve actual axiom checks
report only `propext`, `Classical.choice`, `Quot.sound`.

Proved cardinality 256³, endpoints/bounds/injectivity, difference and minimum spacing,
Euclidean grid coordinates, smallest-index argmin, exact half-down integer rounding
and clipping equivalence, Cartesian nearest-distance optimum, global reconstruction
optimum, exact code round-trip, strict coordinate margin and sufficient Euclidean noise
margin. Broad nlinarith contexts were replaced with `nlinarith only` in rounding proofs;
no resource limits were raised.

Next: finish finite probabilities and coefficient/work counts.


## Revised-source update — 2026-09-26

Original half-down stage passed, but revised §7 explicitly requires ties-to-even.
Stage reopened: add a separate even-tie leaf and prove its nearest/minimizer, clipping,
mode and margin bridges. Preserve half-down results under explicit names. Existing
build/axiom results are evidence for those statements, not revised tie compatibility.

## Active implementation: revised even ties

Current evidence confirms the half-down API and its explicit rounding interval. Add
RGB/EvenRounding as a narrow leaf importing Rounding: correct only odd lower-index
halfway ties, prove a closed Voronoi interval and bounded minimizing property, then
coordinate recovery. Add RGB/EvenDecoding for bank/global/noise bridges. Separate
EvenGridAxioms will audit the new results; no spectral imports in rounding.
Focused commands: `lake build TypeEmbeddings.RGB.EvenRounding`, then
`lake build TypeEmbeddings.RGB.EvenDecoding TypeEmbeddings.Diagnostics.EvenGridAxioms`.
Public root is promoted only after these leaves pass.

## Revised stage results

EvenRounding proves closed Voronoi minimization, explicit even-tie integer formulas,
bounded channel/RGB minimization and strict-margin recovery. EvenDecoding proves
global reconstruction optimality, exact round-trip and Euclidean noise recovery.
Probability/EvenMode proves mode selection, including exact ties. Public root and
EvenGridAxioms build passed (2889 jobs); thirteen actual checks report only
`propext`, `Classical.choice`, `Quot.sound`. No resource limit changes or proof holes.
The decoder uses exact unbounded integers followed by clipping; machine conversion
and FP32 execution remain separate implementation requirements.
