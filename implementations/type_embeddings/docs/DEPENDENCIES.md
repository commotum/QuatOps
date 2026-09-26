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
- `Mathlib.Probability.ProbabilityMassFunction.Constructions`: eventual PMF packaging;
  prove real finite-sum normalization first if that gives cleaner statements.
- `Mathlib.Analysis.SpecialFunctions.Exp`: strictly positive real finite-grid kernels.

The import-only target checks these module paths, not a finished proof design.
No dedicated BF16 semantics or Moore–Penrose API has been selected; neither should
block exact algebra (prove the four Moore–Penrose identities directly if needed).

## Tentative representations

Channel = `Fin 256`; RGB = `Fin 3 → Fin 256`; channel map coerces to ℝ before
subtraction/division. Exact locations use `EuclideanSpace ℝ (Fin 3)` or an explicit
WithLp wrapper. Quaternions use mathlib's ℍ with scalar/i/j/k coordinate order.
A bank is `Fin N → ℍ`. Stacked coordinates may use `Fin N × Fin 4`, of cardinality
4N; flattened `Fin (4*N)` needs an explicit reindexing isometry, not a norm assumption.
Keep algebraic coordinates/matrices separate from metric wrappers where convenient.

Energy can be defined by sum of quaternion norm squares; prove equivalence with norms.
Encode as x ↦ (i ↦ (Px)*Wᵢ). Prefer a real linear-map theorem and derive its matrix
statement through orthonormal coordinate equivalences. Right adjoint must be right
multiplication by conjugate W, with the RGB projection taking imaginary coordinates.

Tie convention proposed: smallest channel index among equal-cost minimizers. Later
prove equivalence to clipped nearest-integer rounding with halfway ties downward.
Finite argmin makes exact correctness independent of implementation rounding APIs.

## Theorem dependency chain

Quaternion norm/adjoint → block Gram; pure insertion isometry + finite-bank sum →
B*B = S id → left inverse and orthogonal projector → Moore–Penrose identities,
least-squares uniqueness, fused reader, singular values, reconstruction bounds →
score decomposition → channelwise global grid optimum and strict-margin recovery.
Grid positivity/finite sums + exp positivity → kernel normalization → RGB product
normalization and modes. BF16 and optional Gaussian statistics require separate semantics.
