# 5-build-time

## Current Facts

- Mathematical stages 1–4 are complete. No prior stage-specific file exists.
- The default warning-as-error build includes all mathematical modules, the
  public root, the autoencoder example and 54 axiom reports.
- Algebra imports all Mathlib.Tactic; Model imports Geometry although it only
  needs the sandwich map, pure preservation and norm scaling.
- Training imports weight calculus and activation proofs unnecessarily.
- ForwardCalculus needs activation and generic training; ParameterCalculus needs
  weight calculus, activation and generic training. The example imports the umbrella.

## Updated Assumptions

- Keep the pinned toolchain, mathlib, default targets and correctness settings.
- Measure project-only clean builds with pinned dependency artifacts cached;
  wall times are local observations, not guarantees on other machines.

## Big Picture Objective

Reduce import overhead and unnecessary incremental rebuilds without changing
mathematical definitions, theorem statements, proofs or axiom dependencies.

## Detailed Implementation Plan

- Record baseline source/API and timed project-only clean build.
- Replace the broad tactic import with the specific tactics used.
- Extract the shared sandwich definitions/basic identities into Conjugation;
  keep unit-isometry/orientation/axis-angle proofs in Geometry.
- Narrow Training, ParameterCalculus and example imports; add explicit required
  dependencies to consumers rather than relying on incidental imports.
- Build focused modules, then all default targets; compare source declarations
  and all axiom reports, scan shortcuts, and record measurements.

## Build Structure

- Conjugation owns existing public sandwich definitions and elementary proof-side
  identities; no new mathematical declarations or global attributes are planned.
- Geometry remains a proof leaf; QNN remains a thin public umbrella.
- Focused commands: `lake build QNN.Conjugation QNN.Geometry QNN.Model`, then
  `lake build QNN.Training QNN.ForwardCalculus QNN.ParameterCalculus`.
- Adjacent consumers: `lake build QNN.ParametricForward Examples.Autoencoder`.
- Full `lake build` is warranted by the high-fanout import changes.

## Boundary Checks

- Preserve every old declaration body after moving it; compare against baseline.
- No proof holes, axioms, unsafe/native shortcuts, weakened targets, disabled checks
  or relaxed warning settings. Audit commands stay in their diagnostic leaf.
- All filesystem changes stay within implementations/qnn.

## Completion Requirements

- Focused and default builds pass with the pinned configuration.
- Axiom output matches all 54 baseline reports.
- Declaration bodies remain identical; only module ownership/imports change.
- Source shortcut scan and scoped `git diff --check` pass.
- Comparable before/after timings and incremental dependency changes documented.

## Stage Results

Complete.

- Added `QNN.Conjugation` by moving the original sandwich block verbatim;
  Geometry retains all rotation/isometry/orientation/axis-angle proofs.
- Narrowed tactic and internal module imports; the public root still reexports
  every previous declaration. No new mathematical declaration was introduced.
- `lake build QNN.Conjugation QNN.Geometry QNN.Model`: exit 0 (2536 jobs).
- `lake build QNN.Training QNN.ForwardCalculus QNN.ParameterCalculus`: exit 0
  (2565 jobs).
- `lake build QNN.ParametricForward Examples.Autoencoder`: exit 0 (2570 jobs).
- Comparable `lake clean qnn` then `/usr/bin/time -p lake build`: baseline
  61.33 s / 3252 jobs; optimized 44.61 s / 2575 jobs, about 27% faster locally.
  Cached dependency artifacts retained; these are single-run measurements.
- Geometry's transitive project consumers fell from 13 to 2 (root and audit).
  Temporary comment-edit build: 5.97 s, only Geometry rebuilt; downstream
  artifacts retained and audit output replayed. Restored source and full build
  passed again. Source import graph confirms neural consumers are independent.
- `lake env lean QNN/AxiomAudit.lean`: exit 0; fresh output matches all 54
  baseline reports byte for byte, with only standard Lean foundations.
- Source snapshot comparison: all original declaration bodies identical, including
  the moved block. Shortcut scan has only the audit documentation comment;
  no proof holes, custom axioms, unsafe/native shortcuts or broad tactic import.
- `git diff --check -- .`: passed. All changes restricted to this project.
- Updated README, dependency/validation notes and `docs/BUILD_TIME.md`.
  Raw evidence is in ignored `.lake/build-time/`. Stage folded into 0-plan;
  no remaining implementation or validation obligation for this maintenance task.
