# 4-probability-counts

## Current Facts

Stages 1–2 compile and have actual axiom audits. Exact grid, half-down clipping,
channelwise optimization and reconstruction decoding now compile; grid audit pending.

## Updated Assumptions

The finite-grid likelihood is a chosen modeling family, not calibration. Channel
scales are explicitly positive. Counts exclude type/text parameters, biases and adapters.
Arithmetic cost assumes unit-cost scalar operations and fixed four-coordinate blocks.

## Big Picture Objective

Prove finite-grid normalization, channelwise joint modes, PMF packaging, and exact
coefficient counts with a stated linear-work model and asymptotic bounds.

## Detailed Implementation Plan

Probability/Grid handles kernels and finite sums without bank/spectral dependencies;
Probability/PMF packages the established real probabilities. Counts/Basic and Cost are
separate low-dependency leaves. Scale-predictor counts remain additional to core counts.

## Build Structure

Build each touched leaf directly, audit main results separately, then update the root.
No spectral, Gaussian, BF16 or empirical claim belongs in probability/count definitions.

## Boundary Checks

Positive finite normalizers, product sums over the complete grid, explicit independence,
no expectation/standard-deviation/calibration inference, no latency claim from counts.

## Completion Requirements

Normalized finite-grid distribution and mode compile. Counts and explicit work bounds
compile. Actual axiom checks, focused builds and declaration-map updates are recorded.

## Stage Results

Generic foundation complete. Probability/Grid, PMF, Counts/Basic, Cost, public root,
and ProbabilityCountAxioms compile; combined build passed (2886 jobs). Thirteen actual
axiom checks report only propext, Classical.choice, Quot.sound. No revised shared-TYPE,
residual-width, joint-likelihood or total structured count is claimed proved.

## Revised-source update — 2026-09-26

The general independent-scale family is retained as reusable infrastructure. Revised
§§6–7 default to one residual-derived common scale; the separate dense scale predictor
is an ablation/extension. Revised total count includes one scalar gain per bank. Those
new obligations are tracked in stage 5, not silently folded into this completed stage.

