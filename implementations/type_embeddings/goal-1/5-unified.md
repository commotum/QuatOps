# 5-unified

## Current Facts

Revised source is `type_value_embeddings_revised_proposal.md` (see docs/REVISION.md).
Reusable foundations and all revised unified core leaves now compile: TYPE codebook,
structural typed interface, residual-width heads, TYPE/common-scale RGB likelihoods,
reconstruction-temperature identity, joint PMF and structured counts/work. Revised ties-to-even compatibility is complete in stage 3.

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
Actual names and hypotheses are mapped in docs/THEOREM_OUTLINE.md.

## Build Structure

Use narrow Bank/Normalization and Reader/Width leaves, separate TypeCode and likelihood
leaves, a common-scale reconstruction likelihood leaf, and a typed joint/interface leaf.
Keep scalar-count extensions in Counts. Choose concrete file names from actual APIs.
Build each touched module directly; public-root and axiom diagnostics after promotion.

Implemented dependency order:

| Leaf | Main prerequisites | Focused target |
|---|---|---|
| Bank/Normalization | Bank/Basic, real square roots | `lake build TypeEmbeddings.Bank.Normalization` |
| Reader/Width | Bank/LeastSquares (exp/log isolated in Reader/Gain) | `lake build TypeEmbeddings.Reader.Width` |
| TYPE likelihood | Euclidean codebook, finite exp sums | `lake build TypeEmbeddings.TypeCode.PMF` |
| Common-scale RGB/Gibbs | Probability/Grid, score decomposition, Reader/Width | `lake build TypeEmbeddings.Probability.Reconstruction` |
| Typed interface/joint | Per-bank readers, TYPE and conditional VALUE laws | `lake build TypeEmbeddings.Typed.Interface TypeEmbeddings.Typed.Probability` |
| Structured counts/work | Counts/Basic and Cost, explicit slot/work model | `lake build TypeEmbeddings.Counts.Structured TypeEmbeddings.Counts.StructuredCost` |

All listed targets passed focused builds. Width does not need
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

Complete. Bank/Normalization, Reader/Width and Gain, TypeCode/Basic/Probability/PMF,
Reader/RGBProbability/TypeProbability/Summary, Probability/Reconstruction,
Typed/Interface/Probability and Counts/Structured/StructuredCost compile. Public root
exports these leaves. Actual declared statement/hypothesis review covers each required
outline obligation; optional/deferred mathematics remains explicitly classified.
UnifiedAxioms has 39 checks; the consolidated 115-result AllAxioms target includes them.
The final public-root/consolidated audit build passed (2906 jobs), with only standard
foundational axioms. Source scans and final record checks are tracked in stage 6.
