# Revised-proposal continuation prompt

Use the fenced prompt to resume implementation in a later session. Updating this
document does not itself start implementation. The plan records the current proof coverage.

```text
Build the verified Lean library for the revised unified Type & Value Embeddings proposal.
Use implementations/type_embeddings/type_value_embeddings_revised_proposal.md as the
mathematical/engineering source; the original proposal is historical provenance.
Work exclusively in implementations/type_embeddings, including records and artifacts.

Read implementations/type_embeddings/goal-1/0-plan.md and
implementations/type_embeddings/goal-1/0-loop.md. Sync with current files and results,
then execute the first unfinished stage and continue through the remaining stages.
This continuation prompt requests implementation, not another scaffold-only pass.
Preserve the reusable quaternion/Gram/reader results while covering revised ties-to-even
RGB decoding, fixed unit TYPE codes, concatenated TYPE/VALUE conventions, positive
residual-derived common width, normalized TYPE/RGB/joint likelihoods, reconstruction-
temperature equivalence, and structured counts including one gain per bank.

Independently verify claims and assumptions, record corrections, use pinned Lean/mathlib,
and follow implementations/BUILD-PLAN.md for narrow modules, focused builds and stage
records. Keep diagnostics outside the public dependency graph, use specific imports,
and measure slow elaboration before changing proof structure. Preserve theorem strength
and kernel checking when optimizing build time. No proof holes or unexplained project
axioms. Keep exact algebra, representation, experiments, architecture choices,
probabilistic assumptions and empirical claims distinct.
Residual width is not calibrated confidence. Grid representability is not exact prediction.
Fold material results and stage status into the plan and leave a clear resumable handoff.
Completion requires the full revised verified core, builds, a faithful declaration map,
correction records and actual main-result axiom audits; report remaining uncertainty plainly.
```
