# Scaffold validation

Status: PASS, 2026-09-25. No mathematical claim has been formalized.

The target is import-only; successful compilation validates toolchain, package
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
- The only project Lean source is import-only, with no project declarations or proofs.
- Original proposal SHA256:
  `08d0e5c4b5646bddd04f26ead1ccdbcd9365ef476eee2cc6206faf50339915ef`.

Only private package copies and setup artifacts within this directory were written.
The manifest contains upstream Git dependencies, not local sibling paths. The cached
build establishes a local pinned setup; it does not demonstrate a fresh online bootstrap.
A main-result axiom audit is deferred because no such results exist. No experiment,
BF16 counterexample, or mathematical identity was independently verified by this build.
