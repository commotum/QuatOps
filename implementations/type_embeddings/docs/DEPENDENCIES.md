# Dependency and representation notes

## Pinned baseline

Lean: `leanprover/lean4:v4.32.0`.
mathlib: `81a5d257c8e410db227a6665ed08f64fea08e997`.
`lake-manifest.json` locks transitive revisions. These are locally available compatible
versions, not a claim about the newest upstream release. Bootstrap/build evidence belongs
in `VALIDATION.md`. No dependency of this package points at another paper's library.

## Candidate infrastructure inspected locally

- `Mathlib.Analysis.Quaternion`: real quaternion inner product, norm multiplicativity,
  `Quaternion.normSq_eq_norm_mul_self`, `Quaternion.linearIsometryEquivTuple`.
- `Mathlib.Analysis.InnerProductSpace.PiL2`: Euclidean coordinate spaces with ℓ² norms.
- `Mathlib.Analysis.InnerProductSpace.Adjoint`: adjoints for the coordinate-free Gram identity.
- `Mathlib.LinearAlgebra.Matrix.ToLin` and `Matrix.ConjTranspose`: matrix/linear-map
  bridges and real transpose as the real specialization of conjugate transpose.
- `Mathlib.Analysis.InnerProductSpace.SingularValues`: `LinearMap.singularValues`,
  `singularValues_fin`, `singularValues_of_finrank_le`. The API uses an infinite
  finitely supported sequence; only its first three values should equal √S.
- `Mathlib.Probability.ProbabilityMassFunction.Constructions`: PMF packaging;
  prove real finite-sum normalization first if that gives cleaner statements.
- `Mathlib.Analysis.SpecialFunctions.Exp`: strictly positive real finite-grid kernels.

The optional `TypeEmbeddings.Diagnostics.Dependencies` target checks these module paths,
not a finished proof design. The public root does not import it.
The four Moore–Penrose identities are proved directly. Numerics/BFloat16 defines
ideal normal representability and a local-binade ties-to-even storage relation; it is
not a general FP32/BF16 execution engine. PMF packaging is already implemented.

## Current representations and revised additions

Channel = `Fin 256`; RGB = `Fin 3 → Fin 256`; channel map coerces to ℝ before
subtraction/division. Exact locations use `EuclideanSpace ℝ (Fin 3)`. Quaternions use mathlib's ℍ with scalar/i/j/k coordinate order.
A bank is `Fin N → ℍ`. Stacked matrices use `Fin N × Fin 4`, of cardinality
4N; flattened `Fin (4*N)` needs an explicit reindexing isometry, not a norm assumption.
Keep algebraic coordinates/matrices separate from metric wrappers where convenient.

Energy is defined by a sum of quaternion norm squares; its norm-square equivalence is proved.
Encode as x ↦ (i ↦ (Px)*Wᵢ). Prefer a real linear-map theorem and derive its matrix
statement through orthonormal coordinate equivalences. Right adjoint must be right
multiplication by conjugate W, with the RGB projection taking imaginary coordinates.

Current `nearestChannel` selects the smallest equal-cost index and its half-down
clipped formula is proved. Revised §7 is implemented in RGB/EvenRounding and EvenDecoding. Mathlib's
`round` is ties toward positive infinity; it cannot be used unmodified as ties-to-even.
Keep the existing half-down API explicit and add the revised convention in a narrow leaf.

Compiled revised additions: generic finite TYPE indices with fixed codes in the same Euclidean
three-space, a positive floor/gain residual-width record, common-scale RGB specialization,
and a dependent sum of TYPE payloads for the joint PMF. Concatenated BankSpace segments
can use an explicit product/isometric coordinate equivalence; do not assume slice isolation.
TYPE equal-norm logits need exact equal norms; stored FP32 approximation is separate.

## Theorem dependency chain

Quaternion norm/adjoint → block Gram; pure insertion isometry + finite-bank sum →
B*B = S id → left inverse and orthogonal projector → Moore–Penrose identities,
least-squares uniqueness, fused reader, singular values, reconstruction bounds →
score decomposition → channelwise global grid optimum and strict-margin recovery.
Grid positivity/finite sums + exp positivity → generic RGB normalization/PMF/modes.
S>0 → N≥1 → 4N−3>0; residual nonnegativity + positive floor/gain → positive width;
finite TYPE support + exp positivity → TYPE normalizer/PMF; equal unit code norms →
dot-product logit equivalence. Common width + reconstruction-score decomposition →
Gibbs-likelihood equivalence. Conditional PMFs → typed joint normalization. Slot cardinality
+ one gain per bank → revised structured counts. BF16 and optional Gaussian statistics
remain separate semantics. See the revised source, REVISION.md and THEOREM_OUTLINE.md.
