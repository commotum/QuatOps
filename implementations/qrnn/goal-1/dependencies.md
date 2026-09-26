# Dependencies and provisional representation decisions

## Setup

Lean is pinned to `leanprover/lean4:v4.32.0`; mathlib to Git tag `v4.32.0` in
`lakefile.toml`. Official matching toolchain reference:
https://raw.githubusercontent.com/leanprover-community/mathlib4/v4.32.0/lean-toolchain
The generated `lake-manifest.json` records the resolved immutable mathlib commit
and transitive revisions (resolved mathlib: `81a5d257c8e410db227a6665ed08f64fea08e997`). Keep `.lake` and mathlib cache here;
do not reuse another paper's mutable project tree. See `validation.md` for actual
fetch/build state. No Python or machine-learning runtime is a library dependency.

## Mathematical dependency graph

1. Real scalar algebra → mathlib `Quaternion ℝ`, finite sums and `Matrix` →
   Hamilton matrix-vector operations and left/right real block representations.
2. Real normed finite-dimensional spaces and Euclidean pairing → continuous
   real linear maps, adjoints/conjugate transpose → affine/split derivative lemmas.
3. `HasFDerivAt` and chain rule + finite-horizon recursion → QRNN differentiation
   → reverse recurrence → shared-parameter gradient correctness.
4. Measure/probability, Bochner integrals, finite second moments → vector variance
   decomposition → Gaussian component moments or specified polar sampler moments.
   Chi density, independence and change of variables are optional deeper work;
   they are not needed merely to sum squared component moments.
5. Hamilton affine maps + Hadamard product + split nonlinearities → QLSTM forward
   architecture. Finite cardinalities + explicit arithmetic cost model → exact
   count identities and conditional asymptotics.

The smoke test checks only `Mathlib.Algebra.Quaternion`; the pinned source also contains
`Mathlib.Analysis.Quaternion`, including the real inner-product instance and
`Quaternion.linearIsometryEquivTuple` to `EuclideanSpace ℝ (Fin 4)`.
This is a promising existing algebra/calculus bridge; it has been inspected but
not imported by this minimal smoke test. Other module paths and available lemmas
must be checked at stage 1.
Do not assume mathlib already has the required real block/adjoint bridge or a
ready-made chi-four distribution theorem.

## Implemented conventions and remaining decisions

- Algebra: `Quaternion ℝ`; vector `Fin n → Quaternion ℝ`; matrix
  `Matrix (Fin m) (Fin n) (Quaternion ℝ)`. Action is sum_j W_ij * x_j,
  weights multiplying on the left. Parameters are quaternion counts n,m.
- Real coordinates in order (r,i,j,k), using `(Fin n × Fin 4) → ℝ` or
  `EuclideanSpace ℝ (Fin n × Fin 4)` for calculus. Resolve component-major versus
  neuron-major flattening by explicit equivalence/permutation; avoid implicit casts.
- Distinguish continuous real-linear derivative from Euclidean gradient obtained
  through a declared inner product. Quaternion notation packages four real gradient
  components; it is not an assumed quaternion-holomorphic derivative.
- Use a separate named componentwise product. A quaternion matrix adjoint is a
  conjugate transpose, not entrywise conjugation alone. Keep left/right operators
  separate throughout.
- Initial h₀ supplied; input `x k` drives step/state `k+1`; finite interface has
  `T` inputs indexed `0..T−1` and `T+1` states, including `T=0`.
  Parameters shared across time; initial state fixed with respect to parameters.
- Start gradients with half squared Euclidean loss and differentiable scalar
  activations, then generic differentiable real loss/readout. Softmax is a coupled
  real map; ReLU needs separate treatment at nondifferentiable coordinates.
- Plain QRNN has hidden bias and no output bias in the printed equations.
  Optional output bias, layers and bidirectionality must be explicit variants.

## Open choices

Decide how much algebra stays directly on mathlib quaternions versus a real
coordinate equivalence, where inner-product structure is supplied, whether to
state derivatives as continuous linear maps first, and how to encode reverse
finite-time recursion. Choose a concrete corrected sampler only after comparing
moment targets with Algorithm 1; preserve the paper sampler as a separate law.
No optimization convergence theorem is planned without an independently specified
objective, algorithm, regularity and stochastic assumptions.

## API findings from implementation

`Mathlib.Analysis.Quaternion` provides the existing real inner-product structure
and linear isometry to Euclidean four-space. `coordinateEquiv` composes that
isometry with `PiLp.continuousLinearEquiv` to the finite product norm. Calculus
modules explicitly select the additive/module instances used by that isometry;
these are existing mathlib structures, not mathematical assumptions.
Quaternion weight calculus uses `Matrix.Norms.Elementwise` (finite product sup
norm). The Euclidean pairing defining gradients is explicitly `matrixPair` or
`vectorPair`; it does not assert that the sup norm comes from that inner product.
In finite dimension the topology suffices for real Fréchet calculus, while the
chosen Euclidean pairing fixes the gradient convention.
