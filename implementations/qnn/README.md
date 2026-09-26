# Quaternion Neural Network and Its Application — Lean scaffold

This folder is an isolated scaffold for an eventual reusable Lean 4 library based
on the supplied paper transcription. **Substantive implementation has not begun.**
The paper is a source to audit, not an authoritative formal specification.

- [Strategy](goal-1/0-plan.md), [working loop](goal-1/0-loop.md), and [continuation prompt](goal-1/0-prompt.md).
- [Paper map](docs/PAPER_MAP.md), [corrections and questions](docs/AUDIT.md),
  [dependencies and design](docs/DEPENDENCIES.md), [proposed declarations](docs/THEOREM_OUTLINE.md),
  and [validation and axiom status](docs/VALIDATION.md).

Tentative order: quaternion geometry; neuron and loss definitions; real
multivariable derivatives and justified backpropagation; separate empirical
validation. All names and representations in the outline are proposals.

Pinned Lean: `leanprover/lean4:v4.32.0`. Pinned mathlib:
`81a5d257c8e410db227a6665ed08f64fea08e997` (locally available v4.32.0 checkout).
`lake-manifest.json` also locks transitive dependencies. `QNN.lean` only imports
infrastructure; it proves no paper claims.

From this folder run `lake build`. On a fresh machine, Lake must first fetch the
locked dependencies; `lake exe cache get` can obtain mathlib build artifacts.
The scaffold was tested using private copies of an existing dependency cache;
there are no absolute local dependencies or symlinks to other paper projects.
See the validation record for exact observed results and limitations.

The current authorization ends at scaffolding. Wait for explicit instructions
before executing the continuation prompt or implementing any stage below.
