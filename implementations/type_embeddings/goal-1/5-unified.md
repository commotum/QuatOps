# 5-unified

## Current Facts

Revised source is `type_value_embeddings_revised_proposal.md` (see docs/REVISION.md).
Reusable quaternion/bank/grid/probability/count leaves compile. TYPE codebook,
concatenated typed interface, residual-width head, TYPE likelihood and revised counts
are not implemented. Revised ties-to-even compatibility is handled first in stage 3.

## Updated Assumptions

Finite nonempty TYPE support; fixed distinct equal-unit-norm codes. Each bank energy
is positive and segment dimension is 4N≥4. Floors/gains are positive. At fixed context,
width/temperature is candidate independent. Default RGB channels share one scale.

## Big Picture Objective

Complete the revised unified TYPE/VALUE mathematical head using existing per-bank
algebra, preserving architecture/modeling distinctions and exact normalization.

## Detailed Implementation Plan

Establish energy-normalization and residual-width positivity/floor/monotonicity;
formalize fixed-code TYPE probabilities and equal-norm logits; specialize common-scale
RGB and prove reconstruction-temperature equivalence; define concatenated interface
and normalized dependent joint PMF; establish revised counts and work bounds.
Names and hypotheses are proposed in docs/THEOREM_OUTLINE.md.

## Build Structure

Use narrow Bank/Normalization and Reader/Width leaves, separate TypeCode and likelihood
leaves, a common-scale reconstruction likelihood leaf, and a typed joint/interface leaf.
Keep scalar-count extensions in Counts. Choose concrete file names from actual APIs.
Build each touched module directly; public-root and axiom diagnostics after promotion.

Provisional dependency order (module names may adapt to actual consumers):

| Leaf | Main prerequisites | Focused target |
|---|---|---|
| Bank/Normalization | Bank/Basic, real square roots | `lake build TypeEmbeddings.Bank.Normalization` |
| Reader/Width | Bank/LeastSquares, exp/log positivity | `lake build TypeEmbeddings.Reader.Width` |
| TYPE likelihood | Euclidean codebook, finite exp sums | Choose a leaf name before implementation |
| Common-scale RGB/Gibbs | Probability/Grid, score decomposition, Reader/Width | Choose a leaf name before implementation |
| Typed interface/joint | Per-bank readers, TYPE and conditional VALUE laws | Choose a leaf name before implementation |
| Structured counts/work | Counts/Basic and Cost, explicit slot/work model | Choose a leaf name before implementation |

These are proposed targets, not existing modules or build evidence. Width does not need
spectral theorems; finite TYPE normalization does not need quaternion coordinates.
Combine these dependencies only in the head/interface consumers that require them.

## Boundary Checks

No transformer slice-preservation assumption. Residual width is not calibration.
Do not use learned per-channel scales as the revised default. No omitted scalar gain
in total counts, unit-norm assertion about quantized codes, or Gaussian law by fiat.

## Completion Requirements

All required stage-5 obligations in the revised theorem outline have reusable compiled statements,
actual main-result axiom checks and map entries. Count example is 514. Conditional
TYPE and VALUE distributions give a full normalized joint law. Top-k, gradients and
hardware performance remain separately classified rather than claimed from algebra.

## Stage Results

Not started; source migration only.
