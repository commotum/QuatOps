# Type & Value Embeddings: Lean library

Quaternion linear algebra and the positive-energy stacked encoder/decoder are proved.
Exact grid decoding, probabilities, counts and numerical scope remain in progress. The original
[type_value_embeddings_proposal.md](type_value_embeddings_proposal.md) is preserved.
All project work, including continuation records, belongs in this directory.

- [Strategy](goal-1/0-plan.md), [working loop](goal-1/0-loop.md), and
  [continuation prompt](goal-1/0-prompt.md).
- [Proposal map](docs/PROPOSAL_MAP.md) and [proposed theorem outline](docs/THEOREM_OUTLINE.md).
- [Audit and corrections](docs/AUDIT.md), [dependencies](docs/DEPENDENCIES.md), and
  [validation](docs/VALIDATION.md).

The tentative direction is right-quaternion multiplication as a real linear map,
then the stacked Gram identity and analytic pseudoinverse, followed by exact RGB
decoding and nearest-grid least-squares optimality. Probability and finite precision
follow separately. This order and the representations remain provisional.

Lean and mathlib are pinned in `lean-toolchain`, `lakefile.toml`, and
`lake-manifest.json`. From this directory, run `lake build`. On a fresh connected
machine, `lake update` and `lake exe cache get` can bootstrap dependencies; retain
and check the committed revision lock. See validation for local bootstrap provenance.

`TypeEmbeddings.lean` is a thin public root exporting completed mathematical leaves.
Candidate imports are checked separately
with `lake build TypeEmbeddings.Diagnostics.Dependencies`; they do not enter the default
build or future consumers through the root. See [build guidance](docs/BUILD.md).
Actual axiom audits are available through `lake build TypeEmbeddings.Diagnostics.QuaternionAxioms
TypeEmbeddings.Diagnostics.BankAxioms`. See the proposal map for compiled theorem names.
