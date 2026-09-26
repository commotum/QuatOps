# Dependencies and representation decisions

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

`Mathlib.Analysis.Quaternion` supplies the existing real inner-product instance
and linear isometry to Euclidean four-space; Algebra and the calculus layer use
it directly. The historical smoke leaf imports Mathlib.Algebra.Quaternion only.
Gaussian moments use Probability.Distributions.Gaussian.Real and HasLaw;
uniform moments use normalized restricted Lebesgue measure, interval integrals
and the independence integration API. All paths/lemmas were checked against the
pinned local source, and the actual mathematical modules compile.

The direct-import cache script builds only the project's required dependency
closure. Architecture/count leaves do not import probability/calculus, and
probability leaves do not import BPTT. Generic BPTT imports FDeriv.Add/Prod only.
Diagnostics are checked explicitly and excluded from the public entry point.

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
  activations, plus generic differentiable real terminal/summed state losses. Softmax is a coupled
  real map; ReLU needs separate treatment at nondifferentiable coordinates.
- Plain QRNN has hidden bias and no output bias in the printed equations.
  Optional output bias, layers and bidirectionality must be explicit variants.

## Resolved choices and explicit limits

Derivatives are continuous real-linear maps, then identified with gradients by
Euclidean component pairings. Generic cotangent recursion is instantiated with
actual QRNN joint derivatives; QRNNGradients evaluates those derivatives and
proves all four explicit parameter families. No project-specific calculus axiom
is used. Norm topology uses finite product/sup norms; gradients retain the stated
Euclidean pairing convention.

InitializationCore defines deterministic polar weights and total normalization.
InitializationMoments separates covariance trace, norm second moment and norm
variance. Gaussian/Uniform law adapters justify the distinct moments. Corrected
bounded sampling uses sqrt(3 target); the original printed sampler remains
available as a separate law. Independence is required only in the explicitly
stated centering theorem, not in polar norm moment identities.

Coordinate equivalences justify counts of actual independent real parameters.
Operation counts describe a dense zero-accumulation forward schedule with scalar
activation costs supplied explicitly; they are not execution-time estimates.
Extra layers/directions/heads, a chi density proof, QLSTM derivatives, coupled
softmax/NLL adapters and optimization/convergence are explicit extensions rather
than hidden assumptions or unfinished required proofs.

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
