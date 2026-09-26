# Verified mathematical core of unified Type & Value Embeddings

## Objective

Build a correct reusable Lean 4 library for the revised proposal
`implementations/type_embeddings/type_value_embeddings_revised_proposal.md`.
Cover the quaternion encoder/reader, exact RGB grid and least-squares decoding,
shared TYPE-code decoding, residual-derived width, normalized TYPE/RGB/joint
probabilities, and justified coefficient counts and arithmetic complexity.
Independently check mathematical claims and record corrections and missing assumptions.
Separate exact algebra, floating-point representation, numerical experiments,
architecture conventions, probabilistic assumptions, and empirical performance.
Deliver pinned builds, reusable declarations, a faithful proposal map, correction records,
and actual main-result axiom audits without proof holes or unexplained project axioms.

## Constraints and known context

- Work exclusively in `implementations/type_embeddings`, including records and artifacts.
- Full implementation is authorized. Follow `implementations/BUILD-PLAN.md` with narrow
  leaves, focused builds, stage records, and a thin public root.
- The revised proposal is authoritative. The original `type_value_embeddings_proposal.md`
  is retained as provenance, not the default design. Source transition: 2026-09-26;
  see `docs/REVISION.md` for the content fingerprint and requirement changes.
- Lean 4.32.0 and mathlib `81a5d257c8e410db227a6665ed08f64fea08e997` remain pinned.
- Existing quaternion/Gram/reader proofs apply independently to TYPE and VALUE banks.
  TYPE/VALUE concatenation is an interface convention; no transformer slice-preservation
  theorem is assumed. Both segment widths are positive multiples of four.
- Right multiplication, pure-imaginary three-coordinate inputs, Euclidean norms, and
  positive total bank energy are essential. Individual zero weights are supported.
- TYPE uses distinct fixed unit codes. Equal-norm score equivalence needs exact equal
  norms of the actual mathematical codes; FP32 storage does not establish this assumption.
- The revised default RGB distribution has one common residual-derived scale. Existing
  independent-channel-scale theorems remain reusable generalizations, not the default head.
- Revised RGB decoding requires ties-to-even. Existing half-down decoding is mathematically
  valid but does not implement that convention; stage 3 is reopened for compatibility.
- Residual width needs a positive floor/gain and positive S(4N−3). No calibrated
  confidence or Bayesian-posterior claim follows. Zero residual can be a wrong prediction.
- Source scripts/results and the cited upstream README are absent locally. Reported
  numerical checks and gradients are not independently verified by this library.
- BF16 representation is separate from rounded-code recovery. Existing ideal-normal
  representation and rounding counterexamples do not specify accelerator or FP32 execution.
- int64, mixtures/autoregressive heads, and multi-input banks need their own hypotheses.
  Top-k search and Gaussian statistics require separate specifications if pursued.

## Ordered stages

### 0. Scaffold and dependency baseline — complete

**Outcome:** Pinned minimal setup, proposal records and continuation scaffold.
**Focus:** Reproducibility and scope, including optional dependency diagnostics.
**Completion signal:** Documents and locked build checked; build-layout record exists.

### 1. Quaternion linear algebra — complete

**Outcome:** Right multiplication as a real linear map and correctly oriented 4×4 matrix,
block Gram law and Euclidean pure-imaginary insertion.
**Focus:** Coordinates, conjugate adjoint and norm multiplicativity, including zero weights.
**Completion signal:** Focused builds and actual quaternion axiom audit pass.

### 2. Bank encoder and analytic decoder — complete

**Outcome:** Stacked Gram and matrix action, analytic fused Moore–Penrose inverse,
injectivity, rank, singular values, condition one, exact recovery and Euclidean error bound.
**Focus:** Positive-energy hypotheses, explicit adjoint, least-squares orthogonality and gain.
**Completion signal:** Bank leaves and public-root build pass with actual main-result audits.

### 3. Exact grid and revised discrete decoding — in progress

**Outcome:** Exact RGB Cartesian grid and global least-squares decoder using the revised
ties-to-even convention, with clipping and strict-margin recovery.
**Focus:** Reuse compiled grid/global-optimum/margin proofs; add an even-tie decoder and
prove its nearest-grid property. Retain half-down results under explicit names.
**Completion signal:** Revised even-tie decoder, clipped formula, global optimality and
margin recovery compile and have actual axiom checks. Existing half-down checks alone
are insufficient. See `3-grid.md`.

### 4. Generic finite-grid probabilities and baseline counts — complete

**Outcome:** Positive channel kernels/normalizers, Cartesian RGB PMF and modes,
coefficient-slot counts, and explicit multiplication-slot O(d) bounds.
**Focus:** Reusable foundations; distinguish independent scales from revised common scale
and baseline core counts from total structured counts.
**Completion signal:** Probability/Counts leaves and ProbabilityCountAxioms build pass.
This stage does not discharge the revised residual/TYPE/joint/count obligations.

### 5. Unified TYPE/VALUE mathematical model — not started

**Outcome:** Exact concatenated interface, fixed-code TYPE likelihood, residual-derived
width, revised common-scale RGB likelihood, reconstruction-temperature equivalence,
normalized joint distribution and revised structured coefficient/work accounting.
**Focus:** Positive nonempty finite supports, unit/distinct codes and separation;
S>0 and 4N−3>0; width positivity/floor/monotonicity; softplus gain and bank normalization;
conditional normalization independent of transformer architecture.
**Completion signal:** Actual declarations cover revised §§3–7,9–10 core obligations
listed in `docs/THEOREM_OUTLINE.md`, compile and are audited. Example count is 514
coefficients for dT=64,dV=448,K=1; optional text is accounted separately.
See `5-unified.md`.

### 6. Numerical scope and final audit — in progress

**Outcome:** Exact representability and checked limitations, updated source map and
complete axiom audit of the revised verified core, with clear remaining exclusions.
**Focus:** Preserve compiled BF16 and wrong-code/multi-input examples; distinguish the
independent witness (0,0,16)→(0,0,17) from the source's unavailable FP32 trace.
Gaussian laws, top-k heaps, gradients, serializers and hardware claims require separate
semantics; record their conditional/deferred/empirical status without inventing proofs.
**Completion signal:** All accepted revised-core obligations, public and diagnostic builds,
source scans, revision mapping and actual main-result axiom audits pass. No completion
claim while stage 3 or stage 5 remains unfinished. See `6-final-audit.md`.

## Session handoff

Source migration performed on 2026-09-26. Stages 1–2 and generic stage 4 compile with
actual audits; original half-down stage 3 compiles but needs ties-to-even compatibility.
BF16 representation and limitation examples compile; final consolidated audit is pending.
Next: implement revised ties-to-even decoding in a narrow leaf, then stage 5's residual
width and fixed-code TYPE likelihood. Preserve the full revised objective and build hygiene.
