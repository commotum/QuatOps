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
- Current task is scaffold only. Scaffold exists; import/build validation is
  recorded in `docs/VALIDATION.md`. All substantive stages below are unstarted.
  Stop after scaffold validation and wait for explicit continuation instructions.
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

### 1. Establish audited quaternion geometry — unstarted

**Outcome:** Exact quaternion and 3D geometry foundations with documented source corrections.
**Focus:** Mathlib quaternion representation; pure-vector equivalence and Euclidean
metric; conjugation, norm, unit conjugation, axis-angle and Rodrigues identities.
**Completion signal:** Relevant reusable declarations compile; equations (1)–(10)
are mapped to proved statements with precise hypotheses and axiom reports.

### 2. Specify the forward model and objective — unstarted

**Outcome:** An explicit finite layered model faithful to justified source definitions.
**Focus:** Eq. (11) scaling/domain, pure thresholds, component sigmoid, layers,
single-output loss, and explicitly labeled multi-output/dataset extensions.
**Completion signal:** Definitions and basic well-formedness/loss results compile;
zero-weight policy, indexing, metrics, and departures from the paper are documented.

### 3. Resolve derivatives and backpropagation — unstarted

**Outcome:** Correct real derivatives and gradient updates, with a clear boundary
between what the paper specifies and what has been independently reconstructed.
**Focus:** Smoothness away from singular weights, ordered multiplication derivatives,
normalization derivative, activation Jacobian, adjoints and finite layer chain rule.
**Completion signal:** Gradient/chain-rule results compile and have axiom reports;
component formulas agree with the real derivative, or unresolved gaps are explained
with evidence. No unstated convergence claim is introduced.

### 4. Consolidate a reusable audited library — unstarted

**Outcome:** Stable abstractions, reproducible builds, final claim coverage, and a
separate optional experimental-validation boundary.
**Focus:** Public interfaces for geometry, networks and training; final axiom and
source audit; examples and documentation; provenance for empirical claims.
**Completion signal:** Clean pinned build; no proof holes or unexplained custom
axioms in completed modules; main results audited; every relevant paper claim
mapped to a declaration or explicit empirical/unsupported/unresolved status.

## Resumption state

Scaffold only. Next authorized implementation action would be to inspect the
pinned quaternion API and resolve the pure-vector representation in stage 1.
Read `docs/AUDIT.md` first. No substantive stage is completed by the import build.
