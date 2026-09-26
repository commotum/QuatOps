# Dependency and representation notes

## Pinned setup

Lean `leanprover/lean4:v4.32.0`; mathlib exact commit
`81a5d257c8e410db227a6665ed08f64fea08e997`. The commit and compatible toolchain
were inspected in an existing clean local mathlib checkout; a remote fetch was
unavailable in the initial sandbox. All transitive Git revisions are locked in
`../lake-manifest.json`. Existing dependency sources/build artifacts were copied
privately into this folder's ignored `.lake/packages`; other projects were not edited.

## Inspected mathlib infrastructure

| Module | Purpose |
| --- | --- |
| `Mathlib.Algebra.Quaternion` | `Quaternion ℝ`, re/imI/imJ/imK, star, normSq, algebra identities |
| `Mathlib.Analysis.Quaternion` | Real inner product, Euclidean quaternion norm, normed algebra |
| `Mathlib.LinearAlgebra.CrossProduct` | Oriented 3-coordinate cross product |
| `Mathlib.Analysis.InnerProductSpace.PiL2` | `EuclideanSpace ℝ (Fin 3)` / finite Euclidean parameter coordinates |
| `Mathlib.Analysis.SpecialFunctions.Sigmoid` | `Real.sigmoid` and real calculus facts |
| `Mathlib.Analysis.Calculus.FDeriv.Mul` | Ordered product differentiation over ℝ |
| `Mathlib.Analysis.Calculus.FDeriv.Comp` | Fréchet chain rule |
| `Mathlib.Analysis.Calculus.Gradient.Basic` | Real inner-product gradient / derivative correspondence |

The scaffold validated imports of these modules. The current library imports
the infrastructure through its implementation modules; actual theorem coverage
is recorded in `PAPER_MAP.md`, not inferred from dependency availability.
The final implementation uses real norm differentiation, finite-coordinate
Jacobian maps, and Hilbert-space adjoints, as described below.

## Chosen representations

The implementation reuses `Quaternion ℝ`. Pure quaternions form
the real-part-zero real subspace, with a proved real linear isometry to
`EuclideanSpace ℝ (Fin 3)` with coordinate order i,j,k. A raw `Fin 3 → ℝ` can be
convenient for coordinates but its default norm must not be confused with Euclidean
norm. Use finite neuron index types and real Euclidean parameter spaces.

Conjugation is `star`; a real denominator acts by scalar multiplication. Explicitly
keep w·x·star(w) in that order. For unit w the implementation supplies a real linear isometry;
oriented-volume and axis-angle theorems justify the spatial-rotation interpretation.

Use `HasFDerivAt` over ℝ and gradients in an identified real inner-product parameter
space. This matches the paper's four real coordinate updates, and does not assert
quaternion analyticity or a left/right quaternion derivative. Build noncommutative
Jacobians and real adjoints before any shorthand gradient expressions. Because
mathlib's gradient is totalized, a gradient value alone is not evidence of
smoothness; state differentiability/domain hypotheses in training results.

Normalization by the norm introduces a singularity at zero; first work on a
nonzero-weight open domain. Keep loss aggregation and any regularization, threshold
updates, or zero extensions explicitly separate from the printed model.

Additional modules actually used: `Mathlib.Analysis.InnerProductSpace.Calculus`,
`Mathlib.Analysis.InnerProductSpace.Adjoint`, `Mathlib.Analysis.Calculus.FDeriv.Star`,
`Mathlib.Analysis.Calculus.FDeriv.Prod`, `Mathlib.Analysis.Calculus.Deriv.Inv`,
`Mathlib.Analysis.SpecialFunctions.Sqrt` and trigonometric identities. A proved
`StarModule ℝ H` instance fills the scalar-conjugation interface; it introduces
no custom axiom. Pure-space completeness is obtained from finite dimensionality.

`Network.pullback` uses strong duals of raw finite signal function spaces.
`Network.euclideanForward` and `euclideanInputDerivative` use `PiLp 2` signal
spaces for adjoints/gradients. The conversion is explicitly continuous-linear,
not advertised as an isometry with the raw supremum norm.

The final training interface selects weights by `Network.WeightIndex`, proves the
real derivative of the actual weight-replaced forward computation, recursively
propagates the output cotangent, and updates all indexed weights from the original
network. `Signal n` fixes the Euclidean output metric. Address transport after
`mapWeights` is explicit, so `trainStep_components` refers to the same connection
position before/after the simultaneous update. Thresholds are kept fixed.

`Examples.Autoencoder` is a separate example library root checked by the default
Lake build, together with `QNN.AxiomAudit`. Project warnings are errors. There is
no executable approximation layer or experimental-data dependency.

`Network.mapWeights_parametric_differentiableAt` allows weights and inputs to vary
jointly in any real normed parameter space. It proves differentiability of the
actual parameterized network from differentiability of each coordinate weight
map, input differentiability and nonzero weights at the point. The corresponding
objective theorem covers the squared-output-error loss. This interface permits
many real parameter layouts without identifying a raw function-space norm with
the Euclidean gradient metric.
