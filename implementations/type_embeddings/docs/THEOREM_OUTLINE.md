# Revised theorem outline and implementation status

Source: `../type_value_embeddings_revised_proposal.md`. Existing exact declaration
names are mapped in `PROPOSAL_MAP.md`. New names below are proposed, not implemented.
All future completed modules must compile without holes/custom axioms.

## Compiled reusable foundation

- Quaternion right multiplication/coordinate action and Gram law; pure RGB insertion.
- Finite-bank linear-map and matrix Gram, Moore–Penrose identities, fused inverse,
  least-squares orthogonality/decomposition, rank, singular values and error/operator norms.
- Exact grid endpoints, spacing, injectivity, cardinality and coordinate margin recovery.
- Half-down nearest-grid decoding, clipping equivalence and global RGB optimum.
- General factorized RGB normalization/PMF/mode; baseline coefficient-slot and O(d)
  multiplication-slot counts. These allow different scales, a broader family than revised default.
- Ideal normal BF16 representation/dyadic facts and compiled limitation witnesses;
  their consolidated axiom audit is pending.

## Stage 3: required revised tie compatibility

Propose `roundTiesEven`, `nearestChannelEven`, `nearestChannelEven_minimizes`,
`nearestChannelEven_ties`, clipped-round equivalence, `decodeRGBEven_global_minimizer`,
`decodeRGBEven_exact_of_margin`, and its Euclidean noise corollary. Preserve existing
half-down APIs. Both bins minimize at exact halfway points; do not infer uniqueness.
Clamping the location before bounded integer conversion should preserve the decoded
mode. Likelihood evaluation must use the original unclamped location.

## Stage 5: revised unified mathematics

The table specifies required core obligations except the explicitly optional greedy-mode
counterexample. Names are tentative; reusable statements and checked hypotheses determine
coverage, not the spelling of a declaration.

| Proposed obligation | Exact statement and assumptions |
|---|---|
| `typeCodebook`, separation | Finite nonempty TYPE support; distinct codes in Euclidean three-space. Equal unit norms are explicit assumptions; minimum positive pairwise distance needs at least two types |
| `typedEmbedding`, reader projections | Concatenate independently encoded TYPE and VALUE segments; prove projection/round-trip identities for this defined code only, with each energy positive |
| `bankDegrees_pos` | S>0 implies N≥1, hence the real denominator d−3=4N−3 is positive |
| `residualVariance`, floor/positive/monotone | v(h)=floor²+γ‖residual h‖²/[S(4N−3)], with floor>0,γ>0,S>0. Monotonicity concerns residual energy with bank/floor/gain fixed |
| `softplusGain_pos` | log(1+exp ρ)>0; gain-one initialization is an exact real equation, not an FP32 exactness assertion |
| `normalizedBank_energy` | Scaling a raw nonzero bank by sqrt(S0)/sqrt(Sraw) gives S0, for S0>0. Quantized actual weights require their own computed denominator |
| `readerSummary` | Expose location, positive kernel scale sqrt(v), squared residual and normalized probabilities; no field asserts calibrated confidence |
| `typeNormalizer_pos`, `typeProbability_sum`, PMF | Normalize exp(−‖aτ−μ‖²/(2v)) over nonempty finite support with v>0 |
| `type_logits_equal_norm` | If all code norms equal, distance logits differ from ⟨aτ,μ⟩/v by a candidate-independent offset; unit norm is a sufficient special case |
| `type_code_recovery` | Distinct finite codes with separation δ>0 decode correctly under strict δ/2 location error; handle one-type case separately |
| `rgbReaderProbability_sum`, mode | Specialize generic RGB PMF to one common positive residual-derived scale; even-tie nearest decoding is a mode |
| `rgb_reconstruction_likelihood` | Normalized exp(−‖h−Bφ(c)‖²/[2Sv(h)]) equals the common-scale factorized PMF. S,v>0 and temperature constant across candidates at fixed h |
| `typedJoint_sum`, conditional sampling law | Normalized TYPE probabilities and each finite conditional VALUE PMF give a normalized joint law on a dependent sum of payload types |
| `greedyType_not_jointMode` | Optional checked finite counterexample: modal TYPE followed by conditional mode need not maximize joint probability |
| `structuredCoefficient_count` | TYPE bank + K VALUE banks + K+1 gain slots has dT+K dV+(K+1) trainable coefficients; fixed codebook storage excluded |
| `structured_512_count` | dT=64,dV=448,K=1 gives 512 bank slots +2 gain slots =514 |
| `structured_output_cost` | Explicit single-branch scalar-work model bounded by O(dT+dV+TYPE count+768); distinguish mode-only, normalization, and multiple-branch search |

A full-column-rank generic real inverse, Gaussian covariance/unbiased residual estimates,
int64 serialization, mixtures/autoregressive heads and exact heap top-k are separate
extensions. Gaussian statistics require an actual noise law and finite moments; heap
claims require sorted channel costs, visited-set invariants and a cost model. Source
reference tests do not discharge any such theorem. Gradients, model quality, calibration,
hyperparameter optimality, checkpoints and accelerator latency remain outside the core.
