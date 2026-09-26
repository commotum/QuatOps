# Revised theorem coverage and extension outline

Source: `../type_value_embeddings_revised_proposal.md`. Existing exact declaration
names are mapped in `PROPOSAL_MAP.md`. The required core below now has compiled declarations; exact names follow.
Completed modules have no proof holes or custom axioms.

## Compiled reusable foundation

- Quaternion right multiplication/coordinate action and Gram law; pure RGB insertion.
- Finite-bank linear-map and matrix Gram, Moore–Penrose identities, fused inverse,
  least-squares orthogonality/decomposition, rank, singular values and error/operator norms.
- Exact grid endpoints, spacing, injectivity, cardinality and coordinate margin recovery.
- Half-down and revised ties-to-even nearest-grid decoding, clipping and global RGB optimum.
- General factorized RGB normalization/PMF/mode; baseline coefficient-slot and O(d)
  multiplication-slot counts. These allow different scales, a broader family than revised default.
- Ideal normal BF16 representation/dyadic facts and compiled limitation witnesses;
  included in the consolidated main-result axiom audit.

## Stage 3: revised tie compatibility — compiled

`roundTiesEven_interval`, `roundTiesEven_halfway_eq` and
`nearestChannelEven_minimizes` implement and verify exact even-tie rounding and clipping.
`nearestRGBEven_global_minimizer`, `decodeRGBEven_roundTrip`,
`decodeRGBEven_exact_of_margin`, `decodeRGBEven_exact_of_noise` and
`rgbProbability_even_mode` provide optimization, recovery and probability bridges.
Both adjacent bins are modes at exact ties; no uniqueness is asserted. Integer conversion
uses mathematical unbounded integers. Finite machine conversion and overflow guards are
separate numerical implementation requirements.

## Stage 5: revised unified mathematics — compiled

| Obligation | Actual declaration / explicit scope |
|---|---|
| Fixed TYPE codes and separation | `TypeCodebook`, `TypeCodebook.exists_separation`; finite nonempty support, injective unit codes; positive uniform bound, not an off-diagonal minimum for a singleton |
| Concatenated interface | `typedEmbedding`, `typedEmbedding_type_roundTrip`, `typedEmbedding_value_roundTrip`; structural segment pair, separate energies; no norm or transformer slice-preservation assertion |
| Positive residual degrees | `residualDegrees_pos`; S>0 implies N≥1 and 4N−3>0 |
| Residual variance | `residualVariance_floor`, `residualVariance_pos`, `residualVariance_mono`, `residualVariance_strict_mono`, `residualVariance_eq_floor_iff`; bank/floor/gain fixed |
| Softplus gain | `softplusGain_pos`, `softplusGain_one`, `widthParametersSoftplus`; exact real initialization |
| Fixed bank energy | `normalizedBank_energy`, `normalizedBank_pos`; nonzero raw energy; stored/quantized energy is a separate numerical concern |
| Reader API | `ReaderSummary`, `rgbReaderSummary`, `typeReaderSummary`; location, positive kernel scale, nonnegative consistency residual and PMF |
| TYPE probabilities | `typeProbability_sum`, `typePMF`, `typePMF_mode`, `typeReaderPMF`; finite positive normalizer and positive modeled variance |
| Equal-norm logits | `type_logits_equal_norm`; actual exact squared norms equal κ, variance nonzero |
| TYPE recovery | `nearestType_exact_of_margin`; strict half-separation location error, ties unspecified |
| Common-scale RGB | `rgbReaderProbability_sum`, `rgbReaderProbability_mode`, `rgbReaderPMF`; one residual-derived positive scale |
| Reconstruction likelihood | `rgb_reconstruction_likelihood`, `readerTemperature_pos`, `rgbReader_reconstruction_temperature`; T(h)=2S v(h), constant across candidates |
| Typed joint law | `typedJoint_sum`, `typedJoint_type_marginal`, `typedJointPMF`; normalized nonnegative finite conditional laws on a dependent sum |
| Structured coefficients | `structuredCoefficient_count`, `structured_512_count`; 4NT+K(4NV)+(K+1), example 514; fixed codebook/text/adapters excluded |
| Structured work | `structured_output_work_bound`, `structured_output_cost`; explicit conservative scalar-work model, one selected VALUE branch, fixed cost per scalar operation |

The optional greedy-TYPE/joint-mode counterexample is not implemented; no joint-maximization
claim is made. Sampling is specified by the normalized joint mass formula, not an executable
random sampler. Both are distinct from calibration.

A full-column-rank generic real inverse, Gaussian covariance/unbiased residual estimates,
int64 serialization, mixtures/autoregressive heads and exact heap top-k are separate
extensions. Gaussian statistics require an actual noise law and finite moments; heap
claims require sorted channel costs, visited-set invariants and a cost model. Source
reference tests do not discharge any such theorem. Gradients, model quality, calibration,
hyperparameter optimality, checkpoints and accelerator latency remain outside the core.
