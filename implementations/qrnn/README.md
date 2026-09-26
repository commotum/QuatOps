# Quaternion recurrent neural networks in Lean

A verified mathematical library based on
[Quaternion_Recurrent_Neural_Networks.md](Quaternion_Recurrent_Neural_Networks.md).
All project files, goal records, dependencies, caches and build artifacts stay in
this folder. Lean/mathlib are pinned to v4.32.0; the manifest locks exact revisions.

The public API is [Qrnn.lean](Qrnn.lean). Import a specific module to keep
incremental builds small:

| Module | Verified surface |
|---|---|
| Algebra | Quaternion vectors/matrices, ordered Hamilton products, left/right real blocks, matrix expansion and Euclidean adjoints |
| ActivationCore / Forward | Split activations and typed QRNN/QLSTM forward definitions |
| Activation / Derivatives / Loss | Ordinary real Fréchet derivatives, local pullbacks, explicit half-squared loss |
| BPTT | Quaternion-independent finite-horizon real BPTT |
| QRNNBPTT / QRNNGradients | Actual QRNN joint derivatives and recurrent/input/output/bias gradients for terminal and summed output losses |
| InitializationCore / InitializationMoments | Polar norm algebra and separate covariance-trace / norm-variance identities |
| InitializationGaussian / InitializationUniform | Actual Gaussian/uniform component laws and corrected initialization moments/scales |
| QLSTMReal | Real-coordinate step and finite-horizon cell/hidden recurrence |
| ParameterCounts / OperationCounts | Independent coordinate bijections, exact architecture counts and conditional forward arithmetic costs |

The real-coordinate order is (r,i,j,k), with neuron-major indices. Weights act on
the left. Initial states are fixed; input k drives state k+1. Gradients use
Euclidean four-component pairings, with scalar differentiability at visited
preactivations explicit. The concrete output-loss theorems use half squared
error and split activations. Generic real terminal/summed loss calculus is also
available. No quaternion-holomorphic derivative is assumed.

Material corrections: QBPTT composes Jacobian pullbacks and sums local gradients;
it does not multiply propagated errors. Matrix pullbacks use conjugate transpose.
The bounded polar sampler has norm second moment σ²/3, mean norm σ/2 and norm
variance σ²/12; Gaussian components instead give norm second moment 4σ².
Fourfold parameter saving applies exactly to weights at matched real widths,
with explicit bias corrections for whole models. QLSTM candidate Hamilton
multiplication is a documented interpretation of missing source symbols.

TIMIT/WSJ performance, training speed and optimization/convergence claims are
experimental or unsupported by this mathematical development. Chi-density/law
identification, QLSTM derivatives and coupled softmax/NLL adapters are outside
the current verified surface. Their absence is recorded, not supplied as axioms.

To obtain the pinned dependencies and their targeted build cache:

```sh
MATHLIB_NO_CACHE_ON_UPDATE=1 lake update
python3 scripts/cache-mathlib.py
bash scripts/check.sh
```

The cache script collects this project's direct mathlib imports and keeps their
closure in `.cache/mathlib`. It does not fetch all mathlib. Ordinary development
uses focused builds, for example `lake build Qrnn.QRNNGradients`; build adjacent
consumers after import changes. Run the public build and explicit audit for API
integration. For a clean project check retaining dependency caches:

```sh
lake clean qrnn
bash scripts/check.sh
```

`check.sh` builds the API and separate diagnostics, checks the main-result kernel
axioms, scans proof holes/import boundaries, checks pins/source checksum and
runs the scoped whitespace check. Diagnostics are not public API imports.

See [paper map](goal-1/paper-map.md), [corrections](goal-1/audit.md),
[dependencies](goal-1/dependencies.md), [theorem outline](goal-1/theorem-outline.md),
and [validation](goal-1/validation.md). The staged goal record is
[goal-1/0-plan.md](goal-1/0-plan.md); historical scaffold checks remain labeled.
