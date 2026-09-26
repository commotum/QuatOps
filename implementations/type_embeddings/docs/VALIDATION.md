# Current revised-core validation

The revised mathematical core compiles under pinned Lean 4.32.0 and mathlib
`81a5d257c8e410db227a6665ed08f64fea08e997`. All nine private package HEADs match
`lake-manifest.json`. Source proposal fingerprints are unchanged.

`lake build TypeEmbeddings.Diagnostics.AllAxioms TypeEmbeddings` passed (2906 jobs).
The consolidated target actually printed 115 distinct main-result axiom dependencies;
each is contained in `propext`, `Classical.choice`, `Quot.sound`. Raw output is
`../goal-1/final-build.log`. Focused builds for all new leaves passed before promotion.
RevisedLimitations and NumericalAxioms passed (2556 jobs), including both revised
counterexamples. Per-leaf elaboration observations were about 1.4–2.9 seconds; these
are local cached observations, not clean-build or portable performance benchmarks.

The mathematical setup uses exact real arithmetic. It does not validate FP32 execution,
source numerical experiments, Gaussian noise statistics, trained models, top-k heaps,
or fresh online dependency bootstrap. Historical evidence follows for provenance;
its scaffold-only/incomplete statuses describe the earlier state.

## Historical scaffold validation — 2026-09-25

Historical status: PASS. At this point no mathematical claim had been formalized.

The original scaffold target was import-only; successful compilation validated toolchain, package
configuration, and candidate import paths. It does not validate proposal mathematics.
Dependency bootstrap uses a private copy of locally available package sources and
compiled artifacts from the neighboring qnn scaffold, with the same exact mathlib
revision and Lean version. No dependency configuration refers to that sibling folder
and no sibling files are modified. Fresh network bootstrap is not tested.

Observed checks, run from `implementations/type_embeddings`:

- `lake build`: exit 0; built `TypeEmbeddings`; “Build completed successfully (2868 jobs).”
- `lake env lean --version`: Lean 4.32.0, commit
  `8c9756b28d64dab099da31a4c09229a9e6a2ef35`, release x86_64-unknown-linux-gnu.
- Every one of the nine package Git HEADs matches its locked manifest revision,
  including mathlib `81a5d257c8e410db227a6665ed08f64fea08e997`.
- Three goal files and all supporting documents exist; continuation prompt paths match.
- At initial validation, the only project Lean source was import-only, with no project declarations or proofs.
- Original proposal SHA256:
  `08d0e5c4b5646bddd04f26ead1ccdbcd9365ef476eee2cc6206faf50339915ef`.

Only private package copies and setup artifacts within this directory were written.
The manifest contains upstream Git dependencies, not local sibling paths. The cached
build establishes a local pinned setup; it does not demonstrate a fresh online bootstrap.
A main-result axiom audit is deferred because no such results exist. No experiment,
BF16 counterexample, or mathematical identity was independently verified by this build.


## Build-layout maintenance validation

At this historical maintenance step the public root had no imports or declarations; the original eight imports reside
in `TypeEmbeddings.Diagnostics.Dependencies`, an optional explicit diagnostic target.
Both compile under the unchanged pins. No theorem/proof was removed or weakened.

Observed commands after the change:

- `lake build TypeEmbeddings.Diagnostics.Dependencies`: exit 0, 2867 jobs, 4.141s.
- `lake build`: exit 0, 3 jobs, 0.970s including root elaboration.
- Repeated `lake build`: exit 0, 3 jobs, 0.829s.

Baseline cached default build was 2868 jobs in 2.179s. Timings are local observations;
job-graph reduction is the structural result. Diagnostic coverage stays available
explicitly. Import boundaries, no project declarations/proof holes, direct whitespace
checks, and repository-root `git diff --check` pass. There remain no mathematical
results to audit. See `../goal-1/0-build-layout.md` and `BUILD.md` for future build rules.


## Mathematical stages 1–2

Focused quaternion Core/Basic/Matrix and Bank Basic/Decoder/LeastSquares/Matrix/Spectral
builds passed. Public API and BankAxioms audit passed together (2726 jobs). Actual
`#print axioms` checks cover eight quaternion and twenty bank main results, each with
only `propext`, `Classical.choice`, `Quot.sound`. This validates those mathematical
statements under their explicit hypotheses, not floating-point execution or model quality.
Subsequent stages remain incomplete; the original scaffold-only statements above are
historical records, superseded by this mathematical implementation status.


## Revised-source documentation migration checks — 2026-09-26

Both original and revised proposal hashes match their recorded fingerprints; neither
proposal was modified. Fourteen relative Markdown links, continuation prompt paths,
reopened stage-3 status and new stage-5 status were checked. Direct whitespace scan
and `git diff --check -- .` pass.

`lake build TypeEmbeddings.Numerics.BFloat16 TypeEmbeddings.Diagnostics.Limitations
TypeEmbeddings` passed (2887 jobs). This confirms current leaves/public root compile;
it does not discharge the new revised-head obligations. The documentation migration
changed no Lean theorem or proof. The dyadic statement's already-pending public-numerator
cleanup was included in this focused validation.

## Documentation-only refresh checks — 2026-09-26

Rechecked both proposal fingerprints, all 14 local Markdown links, continuation paths,
reopened stage-3 and pending stage-5 status, documentation whitespace and scoped
`git diff --check`. All passed. Historical import-only records now carry explicit labels;
proposed stage-5 leaf targets are distinguished from existing compiled modules.
No Lean source, dependency pin or build configuration was changed in this refresh.
No new Lean build was needed or run; earlier build evidence above remains historical.

## Final source/document checks

All 47 Lean sources pass scans for proof holes, custom axiom declarations and unchecked
shortcuts. Internal/public imports do not depend on diagnostics or the umbrella module.
Both proposal SHA256 fingerprints match, all local Markdown links and prompt paths
resolve, stage status agrees with actual coverage, and documentation whitespace/scoped
`git diff --check` pass. The final build log contains no warning/error.
See COMPLETION.md for the full requirement-to-evidence audit.

Final explicit build of all 47 project modules, including optional diagnostics, passed
with exit 0 (2914 jobs). No warnings/errors in goal-1/final-module-build.log.
