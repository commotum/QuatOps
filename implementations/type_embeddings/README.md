# Unified Type & Value Embeddings: Lean library

Active mathematical/engineering source:
[type_value_embeddings_revised_proposal.md](type_value_embeddings_revised_proposal.md).
The [original proposal](type_value_embeddings_proposal.md) is retained as provenance.
See [revision changes](docs/REVISION.md); no full revised-core completion is claimed.

Compiled foundations cover quaternion right multiplication, stacked Gram and fused
pseudoinverse, spectral/least-squares/error results, exact RGB grid and half-down decoding,
generic finite-grid probabilities/PMF, coefficient slots and multiplication-slot O(d).
Ideal-normal BF16 representability and independent limitation examples also compile.

The revised proposal requires ties-to-even decoding, shared fixed-code TYPE scoring,
concatenated TYPE/VALUE conventions, residual-derived common width, a normalized typed
joint law, reconstruction-temperature equivalence and structured counts including gains.
These new obligations remain unfinished. Existing half-down decoding and independent
channel scales are reusable mathematics, not implementations of the revised defaults.

- [Plan](goal-1/0-plan.md), [loop](goal-1/0-loop.md), [continuation prompt](goal-1/0-prompt.md).
- [Source map](docs/PROPOSAL_MAP.md), [theorem outline](docs/THEOREM_OUTLINE.md).
- [Corrections/axioms](docs/AUDIT.md), [dependencies](docs/DEPENDENCIES.md),
  [validation](docs/VALIDATION.md), [incremental builds](docs/BUILD.md).

Lean 4.32.0 and exact mathlib/transitive revisions are pinned. From this directory,
`lake build` checks the public root and its dependencies. Build touched leaves directly
while implementing. Diagnostics are explicit targets, including
`TypeEmbeddings.Diagnostics.QuaternionAxioms`, `BankAxioms`, `GridAxioms`,
`ProbabilityCountAxioms`, and `Limitations`; the optional import smoke target is
`TypeEmbeddings.Diagnostics.Dependencies`. Public/internal leaves do not import diagnostics.

Fresh online bootstrap (`lake update`, `lake exe cache get`) has not been tested here;
local builds use compatible private cached dependencies, as recorded in validation.
All work and artifacts stay inside this project directory.
