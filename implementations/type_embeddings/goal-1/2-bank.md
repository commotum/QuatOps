# 2-bank

## Current Facts

Quaternion Core/Basic/Matrix and their actual axiom audit compile. Pure RGB preserves
Euclidean inner products; the right matrix Gram identity includes zero weights.

## Updated Assumptions

Bank indices are Fin N, output uses PiLp 2 of quaternion blocks (the real ℓ² block
norm). Energy is the sum of normSq. Inverse/uniqueness results explicitly assume S>0.

## Big Picture Objective

Prove the stacked Gram law, analytic fused decoder, injectivity, Moore–Penrose
identities, least-squares decomposition and perturbation bounds; isolate spectral proofs.

## Detailed Implementation Plan

Define finite bank encoder and explicit adjoint in a narrow Basic module; derive its
Gram identity by adjoint pairing and inner-product extensionality. Decode by S⁻¹
scaling. Put least-squares/error and spectral results in separate leaves as needed.

## Build Structure

Bank/Basic owns bank maps and Gram; Bank/Decoder owns analytic readout and inverse;
Bank/LeastSquares owns orthogonal score identity and error bounds; spectral leaf later.
Build each touched module directly, then public root when promoted.

## Boundary Checks

Right conjugate order, Euclidean norms, individual zero weights allowed, no fabricated
axioms/proof holes. No conclusion about arbitrary transformer hidden-state correctness.

## Completion Requirements

Core bank/decoder theorems and actual axiom outputs compile. Spectral and condition
statements remain required before stage completion. Update declaration map and plan.

## Stage Results

Complete. Basic, Decoder, LeastSquares, Matrix, Spectral, BankAxioms, and public-root
builds pass. The last combined root/audit build completed successfully (2726 jobs).
Twenty main-result axiom checks report exactly `propext`, `Classical.choice`, `Quot.sound`.
No proof holes or custom project axioms occur.

Implemented: bank energy/nondegeneracy, encoder and explicit adjoint, Gram laws in both
linear maps and stacked matrices, coordinate action, matrix left inverse, fused decoder,
round-trip/injectivity, four Penrose identities, exact perturbation equation, orthogonal
residual, reconstruction-score decomposition, least-squares uniqueness, Euclidean bound,
rank three, singular-value sequence, condition one, and exact encoder/decoder operator norms.
Positive S is explicit on all inverse/unique/condition assertions; individual weights
may be zero. Spectral proofs are isolated and do not enter basic/grid imports.

Next: exact RGB discretization and its bridge to the reconstruction-score theorem.
