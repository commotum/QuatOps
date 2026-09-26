# 6-integration

## Current Facts

Stages 1–5 have checked Lean implementations. The public API exports all
mathematical/architecture leaves and excludes diagnostics. The explicit audit
selects 102 main results. Pins remain Lean/mathlib v4.32.0 with locked dependency
revisions. Scaffold-era records are labeled historical; the README, map, outline and
current plan now describe the implemented API and explicit limits.

## Updated Assumptions

The verified core covers source algebra, architecture, derivatives, corrected
initialization moments and conditional counts. Chi-density/law identification,
QLSTM gradients, empirical recognition/runtime, general loss/readout adapters,
and optimization/convergence are outside this core, explicitly recorded.
No outstanding required theorem can be hidden behind a green build.

## Big Picture Objective

Finish a reusable library with reproducible validation, an honest source/claim
map, correction records, and kernel axiom audit. Verify every explicit objective
against actual declarations and command results before marking the goal complete.

## Detailed Implementation Plan

Refresh README, dependencies, outline and plan to describe the final API and
assumptions. Provide a targeted cache/build/check command without importing all
mathlib or touching other paper folders. Rebuild project modules from clean local
artifacts while retaining the pinned mathlib cache, then explicitly compile all
diagnostic leaves. Audit axioms, proof holes, public import boundaries and pins.
Record the final completion table and exact command results.

## Build Structure

The public Qrnn entry point is a thin import-only API. Architecture/count and
initialization leaves remain independent of BPTT/calculus. Diagnostics
AxiomAudit/BPTTAudit/InitializationAudit and the dependency smoke leaf compile
explicitly, outside public imports. Clean only this project's .lake/build;
retain .lake/packages and local dependency cache. Final full build is justified.

## Boundary Checks

No sorry/admit/project axioms, unchecked proof execution, relaxed resource limits,
empirical theorem claims, broad global instances, or edits outside this folder.
Kernel-reported axiom dependencies must be a subset of propext, Classical.choice,
Quot.sound. Paper checksum, toolchain and manifest pins must match earlier records.

## Completion Requirements

Requirement table with actual module/declaration/command evidence; clean public
build; explicit smoke/diagnostic build; 102-result kernel audit; proof-hole and
import-boundary scans; git diff --check; honest excluded/unresolved source claims;
README/build instructions and current plan/map/outline. Only then mark complete.

## Stage Results

Completed 2026-09-26. Re-read both the original continuation attachment and the
current active goal attachment before completion; both require the same original
verified-core objective. The completion audit checked actual Lean declarations
and proof signatures, not only prior plan statuses.

| Requirement | Authoritative evidence | Result |
|---|---|---|
| Quaternion vectors/matrices and ordered Hamilton product | Algebra: Q/QVector/QMatrix, hamilton_components; compiled clean | Verified |
| Left/right real block and full matrix representation | leftBlock/rightBlock actions and composition, expand_apply/mul/conjTranspose/injective; actual shapes include zero dimensions | Verified |
| Split activations and QRNN forward recurrence | ActivationCore/Forward; real derivative in Activation; qrnnRun_prefix/expand and finite interface | Verified |
| Correct real calculus underlying quaternion derivatives | Derivatives: local parameter/state/readout proofs, matVec_hasFDerivAt; QRNNGradients: qrnnJointDerivative_apply and partial evaluation | Verified |
| QRNN BPTT, terminal and summed parameter gradients | Generic BPTT + actual QRNN bridge; quaternionBpttGradient_correct, qrnnTerminalGradient_correct, qrnnSequenceGradient_correct | Verified for recurrent/input/output/bias, fixed initial state, scalar derivative hypotheses |
| Conjugation, derivative placement, indexing and first-step boundary | Algebra/Derivatives pullbacks and explicit corrected recursion; time zero includes direct head term; BPTTAudit counterexample | Verified / corrected |
| Quaternion initialization and variance | Core/Moments/Gaussian/Uniform: actual laws, finite moments, centering independence, σ²/3 versus 4σ², σ/2 norm mean and σ²/12 norm variance, calibrated uniform bound | Verified / corrected |
| Zero normalization and direction assumptions | sampled_polar_norm_sq; imaginarySample_nonzero_ae; diagnostic zero counterexample and positive-octant constraint | Verified; no isotropy assumed |
| QLSTM sufficiently specified forward equations | Forward + QLSTMReal step/run real-coordinate equivalence | Verified with documented candidate Hamilton interpretation |
| Exact parameter count | Matrix/QRNN/QLSTM coordinate bijections and finite-index cardinalities; whole-model bias corrections | Verified for stated layer/head/direction conventions |
| Computational complexity | OperationCounts finite schedule indices, exact counts, fixed activation costs, equal-width polynomials and quadratic bounds, sequence schedule | Verified conditional schedule; no wall-clock/BPTT-runtime claim |
| Pinned reproducible setup | lean-toolchain, lakefile.toml, manifest; cache script executed; clean-project check log | Verified Lean/mathlib v4.32.0 and exact commit |
| No proof holes/unjustified project axioms | check.sh source scans; 102 kernel axiom reports in axioms.txt | Only propext, Classical.choice, Quot.sound |
| Reusable API and build-time structure | Thin public entry point; specific mathematical leaves; generic BPTT independent of quaternions; diagnostics excluded | Verified import scans and clean consumers |
| Claim map, corrections, dependencies and outline | paper-map.md/audit.md/dependencies.md/theorem-outline.md linked to actual declarations | Current; historical scaffolding clearly labeled |
| Empirical/optimization separation | No performance/convergence declarations; source-map exclusions and README limits | Recorded outside verified core |
| Scope and source preservation | All created paths under this folder; original SHA-256 checked by check.sh | Passed |

Exact final validation:
- `lake clean qrnn`: removed only this project's generated build artifacts.
- `bash scripts/check.sh`: exited 0; rebuilt public library and explicit smoke/
  diagnostic leaves, 3120 dependency/project tasks. Tasks are not theorem counts.
- Check output: 21 Lean source modules, 102 selected main-result kernel reports,
  Lean 4.32.0 commit 8c9756b28d64dab099da31a4c09229a9e6a2ef35, pins/checksum/
  proof-hole/import-boundary checks passed. See final-check.log and build.log.
- `python3 scripts/cache-mathlib.py`: exited 0, no download required, 3084 cached
  dependency artifacts in the selected closure. See cache-check.log. The helper
  selects 19 direct mathlib imports rather than the whole mathlib library.
- `git diff --check -- .`: passed after the final document fold-back.

No required verified-core work remains. The chi density/law and closed-form
Gaussian norm mean are not formalized; the necessary second moment is proved
from actual Gaussian marginal laws instead. QLSTM gradients, coupled softmax/NLL
adapters, extra architecture variants, convergence and empirical reproduction
are explicit extensions/out-of-core claims, not hidden imported assumptions.
