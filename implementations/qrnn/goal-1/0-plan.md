# Verified quaternion recurrent neural networks

## Objective and scope

Eventually turn the supplied QRNN paper into a correct, reusable Lean 4 library:
quaternion vectors/matrices and Hamilton products, real block representations,
split activations, QRNN recurrence and real derivatives, reconstructed QBPTT and
all recurrent/input/output/bias gradients, initialization and variance, specified
QLSTM forward equations, and exact architecture parameter and operation counts.
Independently audit the source; strongest correct statements or decisive
counterexamples are acceptable outcomes for mistaken claims.

All work, goals, build products, and dependencies stay under
`implementations/qrnn`. Preserve the supplied Markdown. No `sorry`, fabricated
proofs, or unexplained project-specific axioms in completed modules. Pin Lean and
mathlib, map claims to actual declarations, and audit main-result axioms.
Separate algebra identities, architecture definitions, derivative correctness,
optimization assertions, count results, and empirical TIMIT/WSJ results.
The latter and unsupported convergence/performance assertions are outside the
verified core. Differentiability, integrability, nonzero normalization, matrix
shapes, product order, and initial-state assumptions must be explicit.

## Known context and provisional direction

The supplied file is a Markdown transcription; figures and experiment tables
referenced in it are absent locally. Section titles and line locations are in
`paper-map.md`. Preliminary concerns are in `audit.md`; none is a Lean theorem.
Prefer mathlib quaternions with finite vectors/matrices, and structured real
maps for calculus. This direction is provisional: inspect the pinned APIs and
adapt to actual evidence before committing representations. The compact and
appendix QBPTT formulas must be checked against each other and the real chain
rule. Initialization sampling and Gaussian-norm arguments must be distinguished.

## Ordered stages

### 0. Scaffold and stop — complete; stopped
- **Outcome:** paper map, audit targets, design/dependency notes, proposed statements,
  resumable goal files, and a minimal pinned Lean import smoke test.
- **Focus:** scope and evidence for future work; no substantive implementation.
- **Completion signal:** scaffold review and recorded build result; report to the
  user and stop. Even if complete, do not enter stage 1 without explicit instructions.

### 1. Quaternion operations and real representation — complete
- **Outcome:** reusable finite quaternion vectors/matrices, multiplication and
  left/right real representations with dimension and adjoint identities.
- **Focus:** multiplication order, component conventions, block layout, Euclidean
  pairing, conjugate transpose, and separate Hadamard product.
- **Completion signal:** relevant identities compile, have source mappings, and
  pass axiom review; zero-sized shapes and normalization hypotheses are resolved.

### 2. QRNN recurrence and local real derivatives — complete
- **Outcome:** fully typed finite-horizon architecture and verified derivatives
  of split activation, Hamilton-linear layers, output loss, and one recurrent step.
- **Focus:** explicit initial state, fixed parameters, loss normalization and
  scalar activation hypotheses; general real output maps where needed.
- **Completion signal:** real derivative statements compile and compact quaternion
  pullbacks are justified under their exact hypotheses.

### 3. Reconstructed QBPTT and gradients — in progress
- **Outcome:** chain-rule reverse recurrence and recurrent/input/output/bias
  gradients for terminal and summed losses, related to component derivatives.
- **Focus:** ordered Jacobian composition, time-indexed inputs/states, adjoints,
  activation placement, shared-parameter accumulation, and first-step conditions.
- **Completion signal:** gradient correctness theorems compile, paper compact and
  appendix versions have explicit reconciliation or documented counterexamples.

### 4. Initialization and moments — not started
- **Outcome:** rigorous norm/moment statements for explicitly specified random
  quaternion models, separated from initialization optimization heuristics.
- **Focus:** centered vector variance versus variance of its norm, Gaussian
  components versus the paper polar sampler, direction law, zero normalization,
  scale and fan-in conventions. Prefer component moments before a chi density proof.
- **Completion signal:** correct variance statements compile with moment/probability
  hypotheses; sampler mismatches and any chi-law scope are documented.

### 5. QLSTM and architecture counts — forward definitions begun; counts pending
- **Outcome:** sufficiently specified gate/cell recurrence; exact parameter and
  operation counts under a declared architecture and arithmetic cost model.
- **Focus:** Hamilton affine maps versus componentwise gates; candidate-cell
  ambiguity, initial hidden/cell state, output heads, layers and directionality.
- **Completion signal:** forward definitions and conditional count theorems compile;
  comparison dimensions and asymptotic assumptions are explicit.

### 6. Library integration and final audit — not started
- **Outcome:** reusable documented modules, faithful paper-to-declaration map,
  correction record, pinned reproducible build, and main-result axiom audit.
- **Focus:** coherent APIs, clean build, no placeholders or unsupported empirical
  or optimization claims, and honest disposition of unresolved paper claims.
- **Completion signal:** all accepted verified-core objectives compile; each source
  claim is proved, corrected, excluded, or explicitly unresolved; audit reports
  dependencies of main results and no unjustified project axioms.

## Current verified state and session handoff

Continuation was authorized on 2026-09-25. Stage 1 compiled in `Qrnn/Algebra.lean`:
Hamilton components, distinct left/right block actions and composition order,
real matrix expansion/action/composition/injectivity, conjugate transpose,
Euclidean pullback identities, normalization with the nonzero hypothesis, and
separate Hadamard product. Shapes include zero dimensions.

Stage 2 compiled in `Qrnn/Activation.lean`, `Forward.lean`, `Derivatives.lean` and
`Loss.lean`: split real Fréchet derivatives, finite QRNN recurrence and exact real
expansion, local state/readout/recurrent/input/output/bias derivatives, joint
matrix-vector product rule, half-squared-loss derivative and output gradient.
There is also an explicit interpreted QLSTM step, without a correctness theorem
for its gradient or any empirical/optimization claim.

Stage 3 is in progress: generic finite-horizon shared-parameter sensitivity and
reverse-functional BPTT are being checked in `Qrnn/BPTT.lean`. Next bridge the
QRNN parameter space to that generic theorem and establish all accumulated
parameter gradients with a variable output head and terminal/summed losses.
Initialization probability and exact architecture counts remain unfinished.
The full goal is active; current build coverage is not completion of the library.
