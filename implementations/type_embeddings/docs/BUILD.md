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


For the revised proposal, isolate residual-width, TYPE likelihood and typed joint leaves
from the quaternion/grid core; heavy TYPE/probability proof imports must not enter algebraic
Core modules. Keep even-tie rounding separate from the existing half-down proof leaf.
Reopened/new obligations belong in goal-1/3-grid.md and goal-1/5-unified.md. Document
updates alone do not establish revised-head coverage or require broad proof rebuilding.

Completed revised leaves have focused targets under RGB/EvenRounding, Reader, TypeCode,
Probability/Reconstruction, Typed, and Counts/Structured*. The consolidated reproducible
audit command is `lake build TypeEmbeddings.Diagnostics.AllAxioms`; it remains outside
the public graph. Final audit evidence is in goal-1/final-build.log.

## Additional TEXT leaves

Build `TypeEmbeddings.Text.Grouped`, `Decoder`, `Scoring`, `Categorical`, `Retrieval`,
`Counts`, `Spectral`, `Distribution`, `Resolve` or `Model` by exact module name when
touched. Scoring depends on the small grouped algebra, independently of LS inversion,
spectral proofs and categorical probability. Audit/counterexample modules are separate.
The public root exports both architectures; no original proof was weakened.
The combined audit is:

```sh
lake build TypeEmbeddings.Diagnostics.SinglePassAxioms TypeEmbeddings.Diagnostics.AllAxioms TypeEmbeddings
```

The full claim map, ownership/boundaries and final build records for this extension are
in [SINGLE_PASS_AUDIT.md](SINGLE_PASS_AUDIT.md). Historical goal-1 records describe the
completed first architecture, rather than an instruction to overwrite it with TEXT.
