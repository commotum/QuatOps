# Build-time maintenance

Measured locally on 2026-09-25 with the unchanged pinned Lean/mathlib setup.
The relevant import/module and focused-build guidance from
`implementations/BUILD-PLAN.md` was applied within this project.

## Changes

- Replace the high-fanout `Mathlib.Tactic` umbrella with specific tactic imports.
- Move the existing sandwich definitions and elementary identities verbatim to
  `QNN.Conjugation`; both Geometry and Model import this foundation. Rotation,
  isometry, orientation and axis-angle proofs remain in Geometry.
- Narrow Training to Model plus real calculus/gradient/adjoint infrastructure.
  ForwardCalculus explicitly imports Activation; ParameterCalculus explicitly
  imports Calculus, Activation and Training. LayerParameters joins these branches.
- Import Backpropagation directly in the autoencoder example.
- Keep the public QNN root as an import-only umbrella and the axiom audit as a
  diagnostic leaf. No definition, hypothesis, theorem body or global attribute
  was changed. All prior public QNN names remain available from the root.

## Observed measurements

| Check | Before | After |
| --- | --- | --- |
| Clean project build wall time | 61.33 s | 44.61 s |
| Lake jobs in the full dependency graph (includes cached jobs) | 3252 | 2575 |
| Project modules transitively depending on Geometry | 13 | 2 |

The measured clean project build is approximately 27% faster. Each measurement
used `lake clean qnn` followed by `/usr/bin/time -p lake build`, with the same
cached dependency artifacts and default targets. This rebuilds every project
Lean source; it does not rebuild mathlib. These are single local observations,
not a statistical benchmark or a claim about cold dependency builds.

Geometry's only downstream project modules are now QNN and QNN.AxiomAudit. A
temporary comment edit followed by `lake build` took 5.97 s and rebuilt only
Geometry; the audit output was replayed. Lake retained downstream artifacts for
this comment-only change. The original source was restored and the full default
build passed again. The import graph independently confirms that mathematical
changes in Geometry cannot invalidate model, training or example modules.

## Correctness checks

All commands ran from `implementations/qnn` and exited successfully:

```sh
lake build QNN.Conjugation QNN.Geometry QNN.Model
lake build QNN.Training QNN.ForwardCalculus QNN.ParameterCalculus
lake build QNN.ParametricForward Examples.Autoencoder
lake clean qnn
lake build
lake env lean QNN/AxiomAudit.lean
git diff --check -- .
```

The default warning-as-error build compiled all 14 mathematical modules, the
root, example and audit. A source snapshot comparison confirmed every original
declaration body unchanged, with the sandwich block moved verbatim. Fresh
axiom output matches all 54 original reports byte for byte: only
`propext`, `Classical.choice`, and `Quot.sound`. The proof-hole/custom-axiom/
unsafe/native-shortcut scan found only the word “axiom” in the audit module's
documentation comment. No broad Mathlib.Tactic import remains.

Raw logs, timing files, the source snapshot and fresh audit output are retained
locally under ignored `.lake/build-time/`. `docs/AXIOMS.txt` is still current.
The toolchain, lockfile, default targets and Lean correctness settings are unchanged.

## Incremental workflow

Build the modified module first, then its actual consumers. For example, a
rotation-proof change needs `lake build QNN.Geometry QNN.AxiomAudit`; a
connection-calculus change needs ParameterCalculus and its network consumers.
Use the full default build when changing shared imports/API, notation, instances
or configuration. Keep unrelated heavyweight proof surfaces outside internal
consumer imports, and preserve the example/audit checks when measuring speed.
