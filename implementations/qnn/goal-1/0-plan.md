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
- The original scaffold/import validation is recorded in `docs/VALIDATION.md`.
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

### 4. Consolidate a reusable audited library — complete

**Outcome:** Stable abstractions, reproducible builds, final claim coverage, and a
separate optional experimental-validation boundary.
**Focus:** Public interfaces for geometry, networks and training; final axiom and
source audit; examples and documentation; provenance for empirical claims.
**Completion signal:** Clean pinned build; no proof holes or unexplained custom
axioms in completed modules; main results audited; every relevant paper claim
mapped to a declaration or explicit empirical/unsupported/unresolved status.

## Completion state

The preceding turns were progress: they built and verified the geometry, forward
model, real calculus and connection gradients. The final turn proved actual
weight replacement derivatives at every layer, recursive reverse gradients,
simultaneous component updates, joint parameterized forward/loss differentiability,
and bounded axis-angle existence for every unit quaternion.

All stages are complete for the requested mathematical core. The final default
warning-as-error build checks the 13 mathematical modules, root, illustrative
16-4-16 hidden-weight example, and axiom commands. Fifty-four actual audit outputs
contain only standard Lean foundations. `docs/VALIDATION.md` maps the full original
requirements to source declarations and observed checks; `docs/PAPER_MAP.md`
maps the source claims. No proof hole or unexplained project axiom is present.

Source limitations are documented rather than guessed: norm notation/zero
handling, unspecified threshold/batch policy, empirical images/training details,
unsupported convergence/generalization, and the dense parameter-count mismatch.
Completed the mathematical library; further numerical experiments, iterative
convergence theory, alternative normalization or threshold-learning policies would
require a separately specified task and evidence. No required implementation or
proof obligation remains within the original mathematical-core objective.

## Maintenance stage 5 — build time (complete)

Apply the relevant portions of `implementations/BUILD-PLAN.md` within this folder.
Preserve the completed mathematical API, hypotheses and proof integrity; reduce
unnecessary imports and rebuild propagation. The current graph has a broad
`Mathlib.Tactic` import in Algebra and Model depends on all of Geometry.
The import-only refactor preserves all original declaration bodies and hypotheses;
14 mathematical modules now include the extracted Conjugation foundation.
Geometry's downstream project consumers fell from 13 to 2, excluding the neural
model/training/example modules. The public root remains intact.

Focused core/calculus/adjacent builds and the default warning-as-error build all
passed. Comparable project-only clean builds with cached pinned dependencies
measured 61.33 s before and 44.61 s after (about 27% faster locally); full build
jobs fell from 3252 to 2575. All 54 fresh axiom reports match the baseline exactly.
Declaration-body comparison, shortcut scans and scoped diff checks passed.
See `5-build-time.md` and `docs/BUILD_TIME.md` for exact commands, measurement
limits and incremental-build evidence. No maintenance obligation remains.
