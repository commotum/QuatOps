# Current revised-source status

Active source: `type_value_embeddings_revised_proposal.md`, SHA256
`da2d012ff531f71a199a23c010b9ce027605139298c9ca8e691d1b64615f9d1e`.
The source migration changes documentation and scope tracking, not mathematical proofs.
Quaternion/bank, original half-down grid, general finite-grid PMF/counts, ideal BF16 and
limitation leaves have passed focused builds. Revised even-tie compatibility and unified
TYPE/residual-width/joint/count obligations remain unfinished. A full revised-core
completion/audit is not claimed.

Generic probability/count root and audit build passed (2886 jobs), with thirteen actual
axiom checks showing only propext, Classical.choice and Quot.sound. Ideal BF16 and
Limitations focused builds passed. The numerical/limitation consolidated audit is pending.
Historical scaffold timing/job counts below describe that earlier import-only state;
they are not the current mathematical library's dependency graph.

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
