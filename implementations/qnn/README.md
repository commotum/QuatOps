# Quaternion Neural Network and Its Application — Lean library

A reusable Lean 4 formalization in progress, based on the supplied paper
transcription. The paper is audited as a source rather than accepted as a specification.

The library currently covers quaternion identities and corrected norm formulas,
pure quaternions as Euclidean 3-space, unit conjugation and Rodrigues' rotation
formula, finite neurons and layered forward networks, sigmoid activation, squared
error, the normalized weight derivative over ℝ, and gradient/chain-rule building
blocks. It also includes a recursive reverse pass for input differentials and a
concrete connection-weight gradient. **Full hidden-layer weight-gradient assembly
and final library consolidation remain unfinished.**

- [Strategy](goal-1/0-plan.md), [working loop](goal-1/0-loop.md), [continuation prompt](goal-1/0-prompt.md).
- [Current paper map](docs/PAPER_MAP.md), [corrections and questions](docs/AUDIT.md),
  [dependency/design notes](docs/DEPENDENCIES.md), [historical theorem outline](docs/THEOREM_OUTLINE.md).
- [Validation record](docs/VALIDATION.md), [actual axiom output](docs/AXIOMS.txt).

Pinned Lean: `leanprover/lean4:v4.32.0`. Mathlib:
`81a5d257c8e410db227a6665ed08f64fea08e997`. Transitive dependencies are locked.
All project artifacts and private dependency copies are inside this folder.

From this folder run:

```sh
lake build
lake env lean QNN/AxiomAudit.lean
```

On a fresh machine, Lake needs to fetch the locked dependencies;
`lake exe cache get` can obtain mathlib build artifacts. Validation here used
private copies of clean dependency sources/artifacts, with no absolute local
package dependencies. Fresh network bootstrap has not been tested.

The neuron uses the printed single norm denominator, a subtractive pure threshold,
and a component sigmoid. Its total zero-weight extension is explicitly documented;
weight derivative theorems require nonzero weights. Output-error summation is an
explicit extension of the displayed one-output loss. No convergence, generalization
or PSNR superiority theorem is claimed. The reported experiments remain a separate
source-evidence layer.
