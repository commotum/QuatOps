# Quaternion Neural Network and Its Application — Lean library

A reusable Lean 4 formalization of the mathematical core of the supplied paper
transcription. The paper is audited as a source rather than accepted as a specification.

The library currently covers quaternion identities and corrected norm formulas,
pure quaternions as Euclidean 3-space, unit conjugation, axis-angle existence and Rodrigues' rotation
formula, finite neurons and layered forward networks, sigmoid activation, squared
error, the normalized weight derivative over ℝ, and gradient/chain-rule building
blocks. It includes a recursive reverse pass for every hidden/output weight and
simultaneous weight updates proved equal to the source's four real-component
partial-derivative equations. These backpropagation formulas were reconstructed
independently; the paper does not print them.

- [Strategy](goal-1/0-plan.md), [working loop](goal-1/0-loop.md), [continuation prompt](goal-1/0-prompt.md).
- [Current paper map](docs/PAPER_MAP.md), [corrections and questions](docs/AUDIT.md),
  [dependency/design notes](docs/DEPENDENCIES.md), [historical theorem outline](docs/THEOREM_OUTLINE.md),
  and [verified learning-rule derivation](docs/DERIVATION.md).
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
package dependencies. Fresh network bootstrap has not been tested. The default build also checks the
axiom commands and the illustrative [autoencoder example](Examples/Autoencoder.lean),
with Lean warnings treated as errors.

The neuron uses the printed single norm denominator, a subtractive pure threshold,
and a component sigmoid. Its total zero-weight extension is explicitly documented;
weight derivative theorems require nonzero weights. Output-error summation is an
explicit extension of the displayed one-output loss. No convergence, generalization
or PSNR superiority theorem is claimed. The reported experiments remain a separate
source-evidence layer.

The main public learning interface is `Network.objective`,
`Network.WeightIndex`, `Network.weightGradient`, and `Network.trainStep`.
`Network.weightGradient_hasGradientAt` proves correctness for each real quaternion
weight parameter; `Network.trainStep_components` proves the simultaneous update
at all layers for an admissible original network. The source loss is `loss`;
`signalLoss_eq_outputLoss` verifies the explicitly chosen multi-output extension.
`Network.mapWeights_parametric_differentiableAt` and
`objective_parametric_differentiableAt` also prove differentiability under
simultaneous changes of weights and inputs in any supplied real normed parameter
space, provided its coordinate weight maps are differentiable and nonzero at the
point. The library does not impose one particular flattened parameter layout.

Material source corrections include the repeated norm component and the claimed
matched parameter counts. Under dense connectivity the quoted architectures have
1,152 real weights versus 512 quaternion weight components (see audit A13).
Original pages, omitted training details and experimental images remain absent;
the library makes no claim to reproduce the authors' experimental implementation.
