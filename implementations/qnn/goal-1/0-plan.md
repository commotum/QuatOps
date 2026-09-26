# A verified, reusable quaternion neural network library

## Objective

Turn “Quaternion Neural Network and Its Application” into a correct reusable
Lean 4 library: quaternion algebra, conjugation and norm; pure quaternions as
3D vectors; conjugation rotations; the forward neuron and component activation;
the stated loss and componentwise gradient updates; and the mathematical core
of backpropagation wherever specified or independently derivable. Keep exact
identities, model definitions, derivative results, learning/convergence claims,
and experimental evidence distinct.

## Constraints and context

- Work exclusively within `implementations/qnn`, including goal records.
- Continuation beyond scaffolding is now explicitly authorized. The original
  scaffold/import validation is recorded in `docs/VALIDATION.md`.
- Use the supplied Markdown transcription; original typeset pages and figure
  assets are not supplied in this folder. Do not silently resolve source ambiguities.
- Independently audit formulas; correct errors and record additional assumptions.
  Reuse mathlib when appropriate and preserve noncommutative multiplication order.
- Completed modules must build with pinned versions, contain no proof holes or
  unexplained project-specific axioms, and expose reusable definitions/theorems.
  Maintain a paper-to-declaration map and actual axiom reports for main results.
- Treat derivatives as real multivariable derivatives unless an alternative has
  been justified. The single norm denominator and zero-weight domain need decisions.
- PSNR/generalization results are reported evidence. The paper explicitly leaves
  its detailed explanation to future work; no convergence or generalization
  theorem follows simply from the update definition.

## Stages

### 1. Establish audited quaternion geometry — complete for paper scope

**Outcome:** Exact quaternion and 3D geometry foundations with documented source corrections.
**Focus:** Mathlib quaternion representation; pure-vector equivalence and Euclidean
metric; conjugation, norm, unit conjugation, axis-angle and Rodrigues identities.
**Completion signal:** Relevant reusable declarations compile; equations (1)–(10)
are mapped to proved statements with precise hypotheses and axiom reports.

### 2. Specify the forward model and objective — complete

**Outcome:** An explicit finite layered model faithful to justified source definitions.
**Focus:** Eq. (11) scaling/domain, pure thresholds, component sigmoid, layers,
single-output loss, and explicitly labeled multi-output/dataset extensions.
**Completion signal:** Definitions and basic well-formedness/loss results compile;
zero-weight policy, indexing, metrics, and departures from the paper are documented.

### 3. Resolve derivatives and backpropagation — complete for source component updates

**Outcome:** Correct real derivatives and gradient updates, with a clear boundary
between what the paper specifies and what has been independently reconstructed.
**Focus:** Smoothness away from singular weights, ordered multiplication derivatives,
normalization derivative, activation Jacobian, adjoints and finite layer chain rule.
**Completion signal:** Gradient/chain-rule results compile and have axiom reports;
component formulas agree with the real derivative, or unresolved gaps are explained
with evidence. No unstated convergence claim is introduced.

### 4. Consolidate a reusable audited library — final validation in progress

**Outcome:** Stable abstractions, reproducible builds, final claim coverage, and a
separate optional experimental-validation boundary.
**Focus:** Public interfaces for geometry, networks and training; final axiom and
source audit; examples and documentation; provenance for empirical claims.
**Completion signal:** Clean pinned build; no proof holes or unexplained custom
axioms in completed modules; main results audited; every relevant paper claim
mapped to a declaration or explicit empirical/unsupported/unresolved status.

## Resumption state

The previous implementation turn was progress: it compiled the quaternion geometry,
forward model, loss, derivative building blocks and connection gradient. The current
turn assembled those into a proved network-wide reverse pass and simultaneous
componentwise weight update for every addressed hidden/output connection.

Stage 3 is complete for the paper's stated real coordinate updates. No flattened
joint-parameter chart, threshold-learning convention, batching convention,
convergence or empirical-superiority theorem is claimed. The multi-output sum is
an explicit extension; zero handling and nonzero derivative assumptions are logged.

Stage 4 is undergoing final evidence checks: full warning-as-error build including
the example/audit targets, refreshed actual axiom output, dependency pins and source
cleanliness, paper-map links, and requirement-by-requirement validation. Finish those
checks before declaring completion. The original full mathematical-core objective
is preserved; unresolved source/experimental details remain explicitly outside the
proved claims, rather than silently guessed.
