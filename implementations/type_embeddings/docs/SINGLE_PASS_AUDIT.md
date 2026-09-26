# Single-pass proposal: proof audit and verification work

Source: ../type_value_embeddings_single_pass_proposal.md. SHA256: `6d2f9a911403cd75ac4746ee4057f2c1c849470878c0779637b7b68754b402e1`.
The completed RGB/unified library remains intact. The user additionally authorized
Lean verification of this text architecture on 2026-09-26.

## Current facts and mathematical differences

TEXT uses m full quaternions (r=4m), disjoint output groups, unit energy per group,
a learned V×r dictionary and bias-free dot-product scores. The earlier RGB bank accepts
a single pure-imaginary quaternion (three real coordinates); its imaginary-only reader
cannot be applied unchanged. The new disjoint groups avoid mixed Gram blocks.
The unnormalized Gram is diag(Sj I4); it is Ir only when each Sj=1.
Scoring uses the adjoint for any stored weights, not the energy-dividing inverse.
No TYPE segment, residual width, Gaussian text likelihood or confidence estimator is
part of this experiment. Terminal normalization follows the host convention.

## Verification plan and build boundaries

Add Text/Grouped for the Euclidean group map and explicit adjoint/Gram,
Text/Decoder for unit-isometry and least-squares/Moore–Penrose consequences,
Text/Scoring for tied score equality and categorical normalization, Text/Retrieval
for deterministic masked argmax and candidate-inclusion correctness, and Text/Counts
for literal coefficient/work accounting. All names are provisional until implemented.
Each module is a narrow leaf; spectral, probability and finite-order machinery stay
out of algebraic core when possible. Build each leaf before promoting through the thin
public root. Diagnostics/SinglePassAxioms supplies actual axiom checks. No new axioms,
proof holes, raised resource limits or assumed ANN recall.

Required qualifications: raw group energy>0; unit energy implies nj≥1 and r≤D;
nonempty finite valid vocabulary and candidate support; consistent validity mask,
authoritative scores and smallest-ID tie rule; finite-precision operation order is
not covered by an exact real identity. Dictionary collisions are permitted by the
architecture and can make token IDs indistinguishable to the scorer.

## Stage results

In progress. Full claim-by-claim mathematical and engineering audit will be recorded
after the additional Lean results compile. Index recall, gradients, text quality,
latency and hardware behavior remain empirical/unverified.
