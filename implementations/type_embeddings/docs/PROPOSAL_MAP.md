# Revised proposal-to-library map

Active source: `../type_value_embeddings_revised_proposal.md`; original proposal is
historical provenance. This map distinguishes actual declarations from planned work.
`THEOREM_OUTLINE.md` specifies new obligations and `REVISION.md` records the transition.

| Revised section | Claim category | Evidence / remaining coverage |
|---|---|---|
| §§1–3 concatenated TYPE/VALUE | Architecture with exact interface underneath | Shared per-bank algebra exists; concatenation/projection/joint-law APIs pending. No slice preservation through transformer assumed |
| §4 RGB MR | Exact algebra / representation | Compiled `channelValue_*`, `rgb_card`, `rgbValue_injective`; `channelValue_bf16` models ideal normal representation |
| §4 TYPE MR | Exact codebook hypotheses / storage convention | Fixed distinct unit-code interface and finite-separation facts pending; FP32 storage is not exact equal-norm proof |
| §5 shared encoder/reader | Exact real linear algebra | Compiled maps, matrix Gram, fused pseudoinverse, spectral/conditioning/reconstruction results apply separately to either bank |
| §6 residual width | Modeling choice with exact positivity underneath | Residual and orthogonality compiled; positive floor/gain, d−3 denominator, width/floor/monotonicity and softplus properties pending |
| §6 Gaussian motivation | Conditional statistical claim | Deferred to an explicit isotropic noise model; no transformer/posterior/calibration implication |
| §7 TYPE likelihood | Exact finite normalization / chosen family | TYPE normalizer, PMF, equal-norm logit equivalence and separation decoding pending |
| §7 RGB likelihood | Exact normalization / chosen common-scale family | Generic channel/product PMF compiles; common residual-width reader specialization and reconstruction-temperature equivalence pending |
| §7 mode | Exact finite optimization | Half-down implementation compiles; required ties-to-even alternative and its mode/global/recovery bridges pending |
| §7 sampling and global joint | Finite probability law | Dependent TYPE/conditional joint normalization pending; greedy-type limitation is not a joint maximization theorem |
| §§7,10 top-k | Algorithm proposal / approximate complexity | Separate future sorted-cost heap specification; not proved by top-1 or reported exhaustive reference check |
| §8 training | Architecture / numerics | Ground-truth bank selection, differentiability, loss implementation and gradient reports are outside current exact core |
| §9 bank normalization | Exact scaling + numerical guard | Fixed-target energy theorem pending; nonzero raw bank and actual stored-weight denominator required |
| §9 precision | Representation and implementation | Compiled ideal-normal BF16 grid and independent rounding counterexample; FP32 execution, overflow guards and source trace remain separate |
| §10 counts | Exact slot cardinalities | Existing core/baseline counts; revised dT+K dV+(K+1), 514 example and text/codebook storage distinctions pending |
| §10 complexity | Explicit arithmetic model / empirical latency | Single-bank multiplication-slot O(d) compiled; TYPE+RGB total work pending. No hardware speedup theorem |
| §11 limits/extensions | Structural restriction / later types | Compiled three-dimensional rank and shared-two-input noninjectivity diagnostic. Int64, mixtures, arbitrary bank sums require new assumptions |
| §12 reference checks | Reported experiments | Revised script/results unavailable; no independent rerun or gradient/top-k theorem claimed |
| §§12–13 quality/rollout | Empirical claims / decisions | Outside verified core; no trained model, calibration or hardware benefit is asserted |

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

The exact half-down convention uses `roundHalfDown t = -round (-t)`; clipping uses
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
FP32 trace. Numerical/limitation main-result axiom consolidation remains pending.
