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

## Boundary Checks

No transformer slice-preservation assumption. Residual width is not calibration.
Do not use learned per-channel scales as the revised default. No omitted scalar gain
in total counts, unit-norm assertion about quantized codes, or Gaussian law by fiat.

## Completion Requirements

All stage-5 obligations in the revised theorem outline have reusable compiled statements,
actual main-result axiom checks and map entries. Count example is 514. Conditional
TYPE and VALUE distributions give a full normalized joint law. Top-k, gradients and
hardware performance remain separately classified rather than claimed from algebra.

## Stage Results

Not started; source migration only.
