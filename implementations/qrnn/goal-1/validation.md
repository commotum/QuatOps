# Validation record

Initial scaffold validated 2026-09-25 from `implementations/qrnn`.
The sections below record that historical scaffold; current checks follow at the end.

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

## Continuation and build-time refactor checks (2026-09-25)

Substantive continuation was subsequently authorized. The earlier import-only
record does not describe today's implementation. Stages 1–2 and the generic/
QRNN state-loss portion of stage 3 now compile; the full goal remains incomplete.

Focused builds passed for BPTT, ActivationCore/Activation/Forward, and
Derivatives/Loss/QRNNBPTT after import-layer changes. `lake build` exited 0:
`Build completed successfully (2436 jobs).` See build.log. An independent
`lake env lean Qrnn/AxiomAudit.lean` exited 0 and reported only propext,
Classical.choice, Quot.sound for all 35 audited results (axioms.txt).
No new project axioms or proof holes were introduced, and diff checks passed.
The toolchain/dependency pins and source checksum remain unchanged.

BPTT's warm-cache direct check took 4.30 s, peak RSS 2967744 KiB before narrowing
imports; after the refactor it took 4.01 s, peak RSS 2554528 KiB. A no-change
public build took 2.22 s. Individual local timings are observations, not portable
performance guarantees; see build-times.txt and 3-bptt.md. The substantive
optimization is the smaller rebuild dependency graph, not a timing promise.

## Completed gradient-stage checks (2026-09-25)

Focused `lake build Qrnn.QRNNGradients Qrnn.BPTTAudit` passed after adding
actual joint-Jacobian evaluation and terminal/summed gradients for all parameter
families. The public API imports QRNNGradients; diagnostics remain separate.
The subsequent `lake build` passed (2437 tasks), and explicit AxiomAudit checking
passed with 47 main results depending only on propext, Classical.choice,
Quot.sound. The newest output is in build.log and axioms.txt. Stage 3 is complete;
initialization, architecture counts, and final integration are still unfinished.

## Initialization-stage checks (2026-09-26)

All four Initialization mathematical modules and the separate diagnostic leaf
passed focused builds. Actual Gaussian/uniform distribution laws were used to
prove moments; scalar norm variance and covariance trace remain distinct.
The public build passed (3114 tasks); explicit axiom checking passed for 76
main results, with only the standard three foundational axioms. See the current
build.log and axioms.txt. Stage 4 is complete; QLSTM/count/cost integration remains.
