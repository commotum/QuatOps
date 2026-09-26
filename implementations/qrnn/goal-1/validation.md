# Scaffold validation

Validated 2026-09-25 from `implementations/qrnn`.

## Observed result

`lake build` exited 0: `Build completed successfully (1513 jobs).`
Both `Qrnn.Smoke` and the `Qrnn` library entry point compiled. These files
contain only a mathlib quaternion import, an entry-point import, and comments.
The job count includes dependency tasks; it is not a count of project theorems.
No substantive definitions or proofs were started.

`lake env lean --version`: Lean 4.32.0, commit
`8c9756b28d64dab099da31a4c09229a9e6a2ef35`.
Mathlib tag v4.32.0 resolved to
`81a5d257c8e410db227a6665ed08f64fea08e997`; its toolchain matches.
`lake-manifest.json` locks transitive dependency revisions.

## Checks passed

- Three required goal files exist; continuation prompt references their actual
  repository-relative paths. Seven indexed stages each have outcome, focus,
  and completion signal; the loop preserves scope and the authorization gate.
- Paper map, audit/correction log, dependency notes and theorem outline exist.
  Proposed declarations are explicitly marked unimplemented.
- Project Lean source contains imports/comments only: no `sorry`, project axioms,
  definitions, or theorem declarations. There are no main-result axioms to audit yet.
- Original paper checksum remains SHA-256
  `a70b427cf99dad35a370b42e0a1fe47223ba89b979d12f9e6c3bd6c67c396717`.
- Created files, dependency checkouts, builds and cache are confined to this folder.

## Reproduction

Run from `implementations/qrnn`:

```sh
MATHLIB_NO_CACHE_ON_UPDATE=1 lake update
MATHLIB_CACHE_DIR="$PWD/.cache/mathlib" lake exe cache get Mathlib.Algebra.Quaternion
lake build
```

Dependency fetching needs network access; the initial restricted-shell fetch
could not resolve GitHub, and an approved network-capable invocation succeeded.
The pinned source's quaternion module is `Mathlib.Algebra.Quaternion` (not a
`Quaternion.Basic` submodule); cache selection uses the module name from this
project root. Only this module's dependency closure was cached (1495 artifacts),
not the complete mathlib library. `.lake/` and `.cache/` are ignored locally.

The successful build validates the setup, not the paper's mathematical claims.
The audit findings remain preliminary; implementation and proofs await explicit
user instructions. No Lean goal-tracking tool goal was opened: the resumable
scaffold lives entirely in `goal-1`.
