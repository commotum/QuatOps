# 3-grid

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

In progress.
