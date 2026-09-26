# Verified mathematical core of Type & Value Embeddings

## Objective

Build a correct reusable Lean 4 library for the proposal's encoder/decoder mathematics,
exact RGB grid, least-squares decoding, normalized finite probabilities, and justified
counts and complexity. Independently verify source claims, correct mistakes and missing
assumptions, and distinguish exact algebra, floating-point facts, experiments,
architecture choices, modeling assumptions, and empirical model/hardware performance.
Deliver pinned builds, reusable theorems, a declaration map, correction records,
and a main-result axiom audit without proof holes or unexplained custom axioms.

## Constraints and known context

- Work exclusively in `implementations/type_embeddings`, including goal records.
- The scaffold is complete; build-layout maintenance follows
  `implementations/BUILD-PLAN.md`. Mathematical implementation is now authorized;
  sync stage status with the actual files and results before continuing.
- The local proposal is the source; its reported verification script and results are
  unavailable in this folder. Numerical results are not independent verification.
- Right multiplication, pure-imaginary RGB input, and S > 0 are essential. Allow zero
  individual weights. All norm bounds must name Euclidean or coordinate maximum norms.
- Prefer mathlib quaternions, real linear maps, Euclidean spaces, matrices, finite sums,
  and probability infrastructure. Do not assume ordinary function-space norms are ℓ².
- Pin Lean 4.32.0 and mathlib 81a5d257c8e410db227a6665ed08f64fea08e997 initially.
- No exact floating-point end-to-end recovery or calibrated confidence follows from
  the algebra. Preserve both counterexample distinctions. Broader types need new assumptions.

## Ordered stages

### 0. Scaffold and dependency baseline — complete

**Outcome:** A reviewable plan, proposal map, corrections/uncertainties, proposed
statements, dependency lock, and import-only validated Lean library.
**Focus:** Preserve the source and set boundaries for future mathematical work.
**Completion signal:** All scaffold documents exist, prompt paths resolve, and the
minimal build result and limits are recorded. Build-layout maintenance is tracked in
`0-build-layout.md`.

### 1. Quaternion linear algebra — complete

**Outcome:** A reusable right-multiplication real linear map, its correctly oriented
4×4 coordinate matrix, and its scaled Gram identity, including zero weights.
**Focus:** Coordinate conventions, conjugation/adjoints, norm multiplicativity,
Euclidean tuple equivalence, and the pure-imaginary isometric insertion P.
**Completion signal:** Coordinate action and R(W)ᵀR(W) = ‖W‖² I₄ compile without holes.

### 2. Bank encoder and analytic decoder — complete

**Outcome:** The stacked encoder B has Gram S I₃; under S > 0 its analytic reader
is its Moore–Penrose inverse, with injectivity, singular values, condition one,
round-trip recovery, fused quaternion expression, and Euclidean error bounds.
**Focus:** Finite banks, sum energy, adjoints, least-squares uniqueness, inverse gain,
and explicit handling of the degenerate bank.
**Completion signal:** Main reusable bank/decoder theorems compile and their actual
axiom dependencies are recorded; no numerical recovery claim is inferred.

### 3. Exact grid and optimal discrete decoding — in progress

**Outcome:** The 256-point channel grid and Cartesian RGB grid are exact, a specified
tie/clipping decoder globally minimizes reconstruction error, and strict half-spacing
perturbations guarantee recovery.
**Focus:** Channel injectivity and spacing, exact nearest-grid selection, orthogonal
score decomposition, coordinate maximum versus Euclidean error, and ties at boundaries.
**Completion signal:** Grid, round-trip, error-margin, and global optimality theorems
compile; ties need not have a unique minimizer.

### 4. Normalized probabilities and definitional counts — not started

**Outcome:** Positive finite-grid kernels define a normalized factorized RGB PMF,
with nearest-grid modes; supported parameter counts and explicit operation-count
models give justified asymptotic claims.
**Focus:** Positive normalizers, finite products/sums, optional joint type factorization,
coefficient versus degree-of-freedom/storage counts, and separating mode from expectation.
**Completion signal:** Normalization/mode/count results compile with explicit assumptions;
no calibration, latency, or quality theorem is claimed.

### 5. Numerical scope, generalizations, and final audit — not started

**Outcome:** Exactly specified representability facts and justified extensions are
proved where feasible; excluded empirical claims and unresolved claims are documented;
the library builds with a complete map and actual main-result axiom audit.
**Focus:** A precise BF16 semantics or an explicitly narrower dyadic representability
statement, counterexamples, Gaussian observation assumptions if pursued, and multi-input
cross terms/full-rank hypotheses before broader typed values.
**Completion signal:** All accepted core obligations are complete, main declarations
have no proof-hole/custom unexplained axioms, and remaining scope limitations are explicit.
An unsupported extension may be resolved by a documented disproof or exclusion.

## Session handoff

Scaffold completed on 2026-09-25. `lake build` passed (2868 jobs); all nine
locked dependency revisions and prompt paths were checked. Quaternion stage declarations
now compile with actual axiom checks. Quaternion and bank stages are complete;
the exact grid stage is in progress. Build-layout maintenance separates optional smoke checks from the public root;
see `0-build-layout.md`. Current work is exact channel grid, tie-aware nearest selection, and global decoding
optimality. Use narrow leaves and focused builds as described in
`docs/BUILD.md`, preserving the full theorem requirements.
