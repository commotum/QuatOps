# Final validation and axiom audit

## Mathematical completion build — 2026-09-25

- `lake build`: exit 0, “Build completed successfully (3252 jobs).”
  The default targets check the `QNN` library, `Examples.Autoencoder`, and
  `QNN.AxiomAudit`; project warnings are errors. All 13 mathematical modules,
  the root import, the example and the axiom-command module compiled.
- `lake env lean QNN/AxiomAudit.lean`: exit 0. The fresh raw output is in
  `AXIOMS.txt`, covering 54 main definitions/results and the hidden-weight example.
- Every printed axiom set is exactly `[propext, Classical.choice, Quot.sound]`.
  These are the usual Lean/mathlib foundations for propositional extensionality,
  classical choice and quotients; no project-specific or proof-hole axiom is used.
- Supplementary source checks found no proof holes, custom axioms, unsafe
  definitions, implementation substitution, or native proof shortcuts in the
  project's Lean code. These checks supplement actual compilation and axiom
  inspection; they do not substitute for them.
- Lean reports 4.32.0, commit `8c9756b28d64dab099da31a4c09229a9e6a2ef35`.
  The mathlib requirement and lock agree on
  `81a5d257c8e410db227a6665ed08f64fea08e997`. All nine dependency HEAD revisions
  match their lock entries, and tracked dependency source files are clean.
- Documentation links, the three goal files, continuation paths, and root-module
  imports were checked against actual files. All project artifacts are in this folder.

## Build-time maintenance — 2026-09-25

The later import-only refactor preserves every original declaration body and
hypothesis, moving the sandwich block verbatim to `Conjugation.lean`. The public
root remains intact; pinned dependencies, default validation targets and warning
settings are unchanged. See [BUILD_TIME.md](BUILD_TIME.md) for current full-build,
axiom, incremental-rebuild and timing results. There are now 14 mathematical
modules after extracting the shared conjugation foundation.

The full attached objective was rechecked against the current supplied source,
mathematical definitions, derivative/update hypotheses and the coverage table.
Fresh `lake build` passed (2575 jobs); fresh direct axiom output matches
`AXIOMS.txt` byte for byte. All 14 mathematical modules are exported by the root,
all nine clean dependency revisions match the lock, and the warning-as-error
configuration is unchanged. Source-integrity and documentation-link checks passed.
The fresh logs are `.lake/build-time/goal-completion-build.log` and
`.lake/build-time/goal-completion-axioms.txt`.

## Requirement-to-evidence completion check

| Requirement | Authoritative evidence |
| --- | --- |
| Quaternion algebra, conjugation and corrected norm | `Algebra.lean`: Hamilton rules, reversed conjugation product, four-term norm/square-root and scalar-product identities; actual build/axiom report |
| Pure quaternions and Euclidean 3-vectors | `Pure.lean`: real subspace, coordinate equivalence, linear isometry, dot/cross multiplication |
| Spatial rotations | `Geometry.lean`: unit conjugation as linear isometry, cross/oriented-volume preservation, bounded axis-angle existence for every unit quaternion, full/orthogonal Rodrigues identities; `Conjugation.lean`: sandwich, norm scaling and composition |
| Forward neurons and layered networks | `Model.lean`: norm-normalized sandwich, subtractive threshold, finite neuron, `Layer` and `Network.forward`; zero convention explicit |
| Componentwise sigmoid | `Model.lean`/`Activation.lean`: three coordinates, range and diagonal real derivative using mathlib sigmoid |
| Source loss and extensions | `loss_components`, `loss_hasGradientAt`; `signalLoss_eq_outputLoss` and its gradient for the explicitly labeled output sum |
| Differentiability and multiplication order | `weightAction_hasFDerivAt`, `weightDerivative_apply`; `ParametricForward.lean` proves joint parameterized forward/objective differentiability under nonzero coordinate weights |
| Backpropagation in every layer | `Network.WeightIndex.hasFDerivAt` differentiates actual weight replacement; `backprop_eq` and `backprop_hasGradientAt` prove recursive reverse propagation gives the real gradient |
| Component partials and weight updates | `componentPartial_hasDerivAt` proves an actual scalar coordinate partial; `Network.trainStep_components` proves all simultaneous hidden/output component updates at admissible original weights |
| Reusable public interfaces | Root imports all mathematical modules; `Network.objective`, `WeightIndex`, `weightGradient`, `mapWeights`, `trainStep`, `updatedIndex`; the checked 16-4-16 example instantiates a hidden update |
| Paper mapping/corrections/assumptions | `PAPER_MAP.md`, `AUDIT.md`, `DERIVATION.md`, `DEPENDENCIES.md`; Eq. (5), norm denominator, zero policy, omitted BP equations, threshold policy, aggregation and parameter-count issue recorded |
| Distinct learning and empirical claims | Paper map/audit identify convergence, generalization and PSNR reports as unsupported or empirical; no such project theorem is asserted |
| Pinned build and proof integrity | Exact toolchain/lock, default warning-as-error build, no proof holes/custom axioms in source, 54 actual axiom reports |

This establishes the requested mathematical library for the explicitly documented
interpretation of the supplied transcription. Its BP formulas are independently
reconstructed, not recovered equations from an omitted implementation.

## Remaining source limits and optional work

The original typeset pages and referenced images are absent. The single denominator
is interpreted as the norm; its zero extension is explicitly defined, while weight
derivative/update correctness requires nonzero original weights. The source does
not specify threshold training, batching, mean/sum dataset aggregation, or robust
handling of iterates that hit zero. The provided training rule keeps thresholds
fixed and uses an explicitly defined finite-output sum. It proves update equations,
not finite-step decrease, nonzero-domain preservation or convergence. These are
recorded boundaries, not unfinished proof obligations in completed modules.

PSNR figures and improved-generalization claims remain source-reported evidence.
No experimental reproduction is claimed. SO(3) surjectivity/double-cover
classification is also not claimed; the implemented geometric results establish
the paper's unit-conjugation and axis-angle rotation identities directly.

Fresh network bootstrap and rebuilding all dependency sources from scratch were
not tested. The initial Git probe failed due to sandbox DNS restrictions; private
copies of clean pinned dependency sources/artifacts were used here. All project
Lean sources were compiled, and there are no absolute local package dependencies.

## Historical scaffold checkpoint

The original import-only setup passed `lake build` (2537 jobs), dependency-pin
checks and goal/path checks. Subsequent implementation replaced that target with
the verified modules listed above; the final audit supersedes the old 32-result
implementation checkpoint.
