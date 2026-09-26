# Revised proposal-to-library map

Active source: `../type_value_embeddings_revised_proposal.md`; original proposal is
historical provenance. This map distinguishes actual declarations from planned work.
`THEOREM_OUTLINE.md` specifies new obligations and `REVISION.md` records the transition.

| Revised section | Claim category | Verified coverage / explicit boundary |
|---|---|---|
| §§1–3 concatenated TYPE/VALUE | Architecture with exact interface | `typedEmbedding` and segment round-trips; structural pair, no transformer slice-preservation or total Euclidean norm claim |
| §4 RGB MR | Exact algebra / representation | Grid, spacing, cardinality and ideal-normal BF16 representability compiled |
| §4 TYPE MR | Exact codebook hypotheses | `TypeCodebook.exists_separation`; fixed distinct unit codes assumed, FP32 exact norms not inferred |
| §5 shared encoder/reader | Exact real linear algebra | Maps, matrix Gram, fused pseudoinverse, spectral/error and least-squares results apply separately to either bank |
| §6 residual width | Modeling rule with exact guarantees | Positive degrees/variance/scale, floor and strict monotonicity compiled; zero residual still permits a wrong code |
| §6 Gaussian motivation | Conditional statistical extension | Explicit isotropic noise law/covariance/expectation not formalized; no calibration or posterior implication |
| §7 TYPE likelihood | Finite normalized chosen family | TYPE probability/PMF, equal-norm logit identity, separation recovery and residual-width reader compiled |
| §7 RGB likelihood | Finite normalized chosen family | Common residual-width PMF and exact positive-temperature reconstruction equivalence compiled |
| §7 mode | Exact finite optimization | Even-tie decoder, clipped integer definition, global optimum, strict margin/noise recovery and probability mode compiled |
| §7 sampling/joint | Finite probability law | Normalized dependent joint and TYPE marginal compiled; no executable sampler or greedy joint mode claim |
| §§7,10 top-k | Separate algorithm proposal | Heap/sorting/visited-set semantics and complexity deferred; top-1 theorem is not top-k proof |
| §8 training | Architecture / numerics | Branch selection, loss/gradient implementation and reports remain outside exact core |
| §9 normalization | Exact real scaling | `normalizedBank_energy`; raw energy positive, target nonnegative (positive target corollary) |
| §9 precision | Representation / checked limitation | Ideal-normal BF16 and independent rounding witness; FP32 execution, hardware guards and source trace separate |
| §10 counts | Exact slot cardinalities | Structured formula and 514 example compiled; fixed codebook, text tables/adapters excluded |
| §10 complexity | Explicit scalar-work model | Single-bank and TYPE+RGB O(dT+dV+types+768) compiled; scalar operations have fixed modeled cost, no latency theorem |
| §11 limits/extensions | Structural restriction / later types | Rank and two-input noninjectivity diagnostic compiled; int64, mixtures and generic multi-input assumptions separate |
| §12 reference checks | Reported experiments | Source script/results unavailable; no independent numerical gradient/top-k rerun claimed |
| §§12–13 quality/rollout | Empirical claims / decisions | No trained model, calibration or hardware benefit asserted |

## Completed declaration map (stages 1–2)

| Proposal claim | Lean declarations | Module |
|---|---|---|
| Right multiplication and coordinates | `rightMulLinear`, `rightMul_conjugate`, `rightMulMatrix_apply` | Quaternion/Core, Matrix |
| Norm multiplicativity and adjoint | `rightMul_norm`, `rightMul_adjoint_pairing`, `rightMul_inner` | Quaternion/Basic |
| Pure-imaginary RGB insertion | `pureRGB_inner`, `pureRGB_norm`, `imaginary_pure`, `pureRGB_adjoint_pairing` | Quaternion/Basic |
| Individual Gram law | `rightMul_gram` | Quaternion/Matrix |
| Total energy and nondegeneracy | `bankEnergy_eq_sum_norm_sq`, `bankEnergy_pos_iff` | Bank/Basic |
| Stacked/encoder Gram | `encoder_gram`, `stacked_gram`, `encoderMatrix_gram` | Bank/Basic, Matrix |
| Coordinate encoder bridge | `encoderMatrix_apply` | Bank/Matrix |
| Analytic inverse | `decoderMatrix_leftInverse`, `decoder_fused`, `decoder_roundTrip`, `encoder_injective` | Bank/Matrix, Decoder |
| Moore–Penrose identities | `penrose_encoder`, `penrose_decoder`, `penrose_projection_symmetric`, `penrose_inverse_symmetric` | Bank/Decoder |
| Noise/error bounds | `decoder_error`, `decoder_error_bound` | Bank/Decoder, LeastSquares |
| Orthogonality and scores | `residual_orthogonal`, `reconstruction_score`, `decoder_unique_leastSquares` | Bank/LeastSquares |
| Rank/singular values/conditioning | `encoder_rank`, `encoder_singularValue`, `encoder_singularValue_tail`, `encoder_condition` | Bank/Spectral |
| Absolute gain | `encoder_opNorm`, `decoder_opNorm` | Bank/Spectral |

All names are in namespace `TypeEmbeddings`; paths are under `TypeEmbeddings/`.
The main results' actual axiom checks are in Diagnostics/QuaternionAxioms and BankAxioms.


## Completed declaration map (stage 3)

| Proposal claim | Lean declarations | Module |
|---|---|---|
| Grid map and cardinality | `channelValue_injective`, `channelValue_zero`, `channelValue_last`, `channelValue_bounds`, `rgb_card` | RGB/Core |
| Spacing / Cartesian embedding | `channelValue_difference`, `channelValue_abs_gap`, `rgbValue_injective` | RGB/Core, Grid |
| Exact rounding/ties/clipping | `nearestChannel_minimizes`, `nearestChannel_tie`, `nearestChannel_eq_round_clip` | RGB/Nearest, Rounding |
| Discrete global optimum | `nearestRGB_minimizes`, `nearestRGB_global_minimizer` | RGB/Nearest, Decoding |
| Recovery | `decodeRGB_roundTrip`, `decodeRGB_exact_of_margin`, `decodeRGB_exact_of_noise` | RGB/Decoding |

The historical half-down convention uses `roundHalfDown t = -round (-t)`; clipping uses
`min 255 n.toNat`, so no unchecked machine-integer conversion is involved.


## Additional compiled foundations (stages 4 and numerical work)

| Claim | Actual declarations | Module |
|---|---|---|
| General channel/product normalization and modes | `channelNormalizer_pos`, `channelProbability_sum`, `rgbProbability_sum`, `rgbProbability_mode`, `rgbPMF`, `rgbPMF_mode` | Probability/Grid, PMF |
| Core/baseline slots | `coreCoefficient_count`, `tiedReal_count`, `untiedRGB_count`, `untiedQuaternion_count`, `untiedPadded_count`, `scalePredictor_count` | Counts/Basic |
| Atomic RGB comparison | `atomicRGB_512_count`, `atomicRGB_512_bf16_bytes`, `channelScore_count` | Counts/Basic |
| Explicit multiplication-slot bounds | `encoderProductCount_eq`, `decoderProductCount_eq`, `encoder_cost`, `decoder_cost` | Counts/Cost |
| Ideal-normal BF16 representation | `channelValue_bf16`, `channelValue_dyadic` | Numerics/BFloat16 |
| Wrong-code consistency / multi-input obstruction | `wrongCode_zeroResidual`, `sharedTwoInput_not_injective` | Diagnostics/Limitations |
| Independent storage-rounding witness | `storageCounter_weights_bf16`, `storageCounter_rounding`, `storageCounter_wrong_decode` | Diagnostics/Limitations |

The compiled witness is (0,0,16)→(0,0,17), using ideal BF16 storage rounding and an
exact real decoder. It is not a reproduction of the source's (237,169,1)→(237,169,0)
FP32 trace. Both half-down and revised even-tie versions of this witness are included in the consolidated audit.

## Revised unified declaration map

The full obligation-to-declaration table is in `THEOREM_OUTLINE.md`. Modules:

| Layer | Modules under TypeEmbeddings/ |
|---|---|
| Even-tie grid/decoder/modes | RGB/EvenRounding, RGB/EvenDecoding, Probability/EvenMode |
| Bank energy and width | Bank/Normalization, Reader/Width, Reader/Gain |
| TYPE support/likelihood | TypeCode/Basic, Probability, PMF |
| Residual-width heads/API | Reader/RGBProbability, TypeProbability, Summary |
| Gibbs identity | Probability/Reconstruction |
| Typed interface/joint law | Typed/Interface, Probability |
| Revised counts/work | Counts/Structured, StructuredCost |
| Preserved revised limitations | Diagnostics/RevisedLimitations |

`Diagnostics/AllAxioms` checks 115 distinct mapped main results and definitions.

## Additional single-pass TEXT architecture

The earlier revised source remains the source of the RGB/unified declarations above.
The [single-pass source](../type_value_embeddings_single_pass_proposal.md) has its own
[complete section-to-declaration map and correction audit](SINGLE_PASS_AUDIT.md).
`Text/Grouped` and `Decoder` establish the full-quaternion group geometry; `Scoring`,
`Categorical`, `Distribution`, `Retrieval` and `Resolve` establish tied probabilities and
conditional canonical candidate correctness. `Counts` and `Spectral` cover dimensions,
coefficient/work counts, rank and unit singular values. `Model` connects these results to
one dictionary/bank and an arbitrary host interface. This adds to the existing API.
