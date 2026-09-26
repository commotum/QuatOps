# Unified Type & Value Embeddings: Lean library

Verified mathematical core of the
[revised proposal](type_value_embeddings_revised_proposal.md). The
[original proposal](type_value_embeddings_proposal.md) remains provenance.

The public library covers quaternion right multiplication, stacked Gram and fused
Moore–Penrose inverse, spectral/least-squares/error results, exact RGB grid and ties-to-even
decoding, finite TYPE/RGB probabilities, residual-derived width, reconstruction-temperature
equivalence, typed segment round-trips, normalized dependent joint laws, and explicit
coefficient/work counts. The revised 64/448 example has 514 learned coefficients.
The original half-down and independent-channel-scale APIs remain reusable alternatives.

Ideal-normal BF16 representation and exact counterexamples compile in separate numerical
and diagnostic leaves. Representation is not exact prediction; floor residual width is not
calibrated confidence. Gaussian statistics, exact heap top-k, int64 serialization, numerical
gradients, trained-model quality and hardware latency are outside this verified core.
No trained transformer or FP32 execution engine is supplied.

- [Plan](goal-1/0-plan.md), [loop](goal-1/0-loop.md), [continuation prompt](goal-1/0-prompt.md).
- [Source map](docs/PROPOSAL_MAP.md), [theorem coverage](docs/THEOREM_OUTLINE.md).
- [Corrections/axioms](docs/AUDIT.md), [dependencies](docs/DEPENDENCIES.md),
  [validation](docs/VALIDATION.md), [completion audit](docs/COMPLETION.md),
  [incremental builds](docs/BUILD.md).

Lean 4.32.0 and mathlib `81a5d257c8e410db227a6665ed08f64fea08e997` are pinned;
`lake-manifest.json` locks transitive revisions. From this directory, run `lake build`
for the public library and `lake build TypeEmbeddings.Diagnostics.AllAxioms` for the
consolidated main-result audit. Build touched leaves directly during changes. Diagnostics
remain outside the public dependency graph; the optional dependency smoke target is
`TypeEmbeddings.Diagnostics.Dependencies`.

Local validation uses private compatible cached packages; all nine HEADs match the manifest.
Fresh online bootstrap (`lake update`, `lake exe cache get`) has not been tested here.
All project edits, records and artifacts stay inside this directory.
