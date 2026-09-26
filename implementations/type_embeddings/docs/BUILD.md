# Incremental Lean builds

Follow the applicable guidance in `../../BUILD-PLAN.md`. All commands run from
`implementations/type_embeddings`. Keep Lean/mathlib pins and kernel checking intact.

- `lake build`: validate the public library root and its actual dependencies.
- `lake build TypeEmbeddings.Diagnostics.Dependencies`: optional candidate-dependency
  smoke check, including spectral and probability infrastructure.
- During implementation, build the touched leaf by its exact module name, then only
  actual adjacent consumers. Run the broader build after public-root/configuration,
  shared notation, instance, or global simplification changes.

Put simple definitions in narrow core modules. Add proof leaves as real consumers need
them; avoid empty feature skeletons. Separate spectral theorems, probability proofs,
finite-precision diagnostics, and axiom audits from quaternion/grid core definitions.
Internal leaves import specific prerequisite modules, never the public root or diagnostics.
Promote finished APIs through the thin root; the default build must cover exported results.

Before changes, update the active stage record with current facts, ownership, boundaries,
and focused commands. After changes, record compilation and scans, then update the plan.
Use small explicit proof steps when broad automation is slow; avoid global simp/instance
changes as an optimization shortcut. No weaker statements, unchecked proofs, changed
axioms, or raised resource limits merely to hide expensive proof search.

Timing cached builds is an observation, not a portable benchmark. The current structural
improvement removes optional imports from the default dependency graph. Future proof
elaboration performance must be measured on actual implementations.
