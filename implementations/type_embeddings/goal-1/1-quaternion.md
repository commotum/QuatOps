# 1-quaternion

## Current Facts

The new attachment authorizes full implementation. Stage 0 and build-layout maintenance
are complete; no mathematical declarations yet exist. Lean/mathlib pins are unchanged.

## Updated Assumptions

Use mathlib `Quaternion ℝ`, real linear maps and scalar/i/j/k coordinates. Multiplication
is on the right. Zero weights must satisfy the block identities. Pure RGB input is
Euclidean; algebraic coordinate functions are not assigned an ℓ² norm implicitly.

## Big Picture Objective

Establish right multiplication's real linear map, coordinate matrix, scaled Gram law,
and the pure-imaginary RGB isometry needed by the bank encoder.

## Detailed Implementation Plan

Add a narrow algebraic Core, a norm/inner-product Basic leaf, and a Matrix leaf. Prove
coordinate action, block Gram, right-conjugate adjoint pairing, and pure RGB metric law.
Promote completed leaves through the public root only after focused builds pass.

## Build Structure

`TypeEmbeddings.Quaternion.Core`: algebraic maps without spectral/probability imports.
`TypeEmbeddings.Quaternion.Basic`: norm and Euclidean insertion results.
`TypeEmbeddings.Quaternion.Matrix`: coordinate matrix and finite Gram computation.
Focused commands: `lake build TypeEmbeddings.Quaternion.Core`, then Basic and Matrix.
Adjacent consumer: `lake build` after public-root promotion. Diagnostics stay separate.

## Boundary Checks

No proof holes/custom axioms. No left/right ambiguity, numerical claims, maximum-norm
substitution, positivity restriction on individual weights, or unused abstraction layers.

## Completion Requirements

Coordinate action and RᵀR=‖W‖²I₄ compile; pure insertion preserves Euclidean inner products.
Record actual main-result axiom output, focused builds, scans, and mapped declarations.

## Stage Results

Focused Core, Basic, Matrix, and QuaternionAxioms builds pass. Matrix elaboration took
3.5s; Basic 2.5s. Eight main-result `#print axioms` commands report exactly
`propext`, `Classical.choice`, and `Quot.sound`, with no proof-hole/custom axioms.
Declarations are promoted through the thin public root. Adjacent build pending.
