# Completion audit of the requested revised mathematical core

Objective reread: the attached continuation instruction and goal-1/0-plan.md.
Evidence inspected: actual definitions/theorem signatures, focused Lean builds,
public-root build, consolidated axiom output, dependency lock/HEADs and source scans.
This audit concerns the mathematical library, not a production transformer prototype.

| Required outcome | Authoritative evidence | Result |
|---|---|---|
| Project/goal artifacts inside the specified folder | All code, docs and build log under implementations/type_embeddings | Pass |
| Pinned compatible Lean/mathlib and transitive dependencies | lean-toolchain, lakefile.toml, lake-manifest.json; actual Lean version and nine package HEAD checks | Pass |
| Quaternion right multiplication as a real linear map and real 4×4 action | rightMulLinear, rightMulMatrix_apply, rightMul_gram; coordinate/sign inspection | Pass |
| Pure-imaginary three-dimensional Euclidean input | pureRGB_inner, pureRGB_norm, imaginary_pure | Pass |
| Finite stacked encoder and scaled Gram | encoder_gram, stacked_gram, encoderMatrix_gram, encoderMatrix_apply | Pass |
| Analytic fused pseudoinverse with explicit S>0 | decoder_fused, decoder_roundTrip, all four penrose_* statements | Pass |
| Injectivity/rank, singular values and condition number | encoder_injective, encoder_rank, encoder_singularValue/tail, encoder_condition | Pass |
| Absolute inverse gain and reconstruction error | encoder_opNorm, decoder_opNorm, decoder_error_bound; Euclidean signatures inspected | Pass |
| Exact RGB grid, cardinality and spacing | channelValue_difference, channelValue_abs_gap, rgb_card, rgbValue_injective | Pass |
| Revised nearest-grid tie convention, clipping and recovery | roundTiesEven_halfway_eq, nearestChannelEven_minimizes, decodeRGBEven_exact_of_margin/noise | Pass |
| Reconstruction decomposition and global RGB optimum | reconstruction_score, nearestRGBEven_global_minimizer | Pass |
| Finite-grid probability normalization and modes | channelProbability_sum, rgbProbability_sum, rgbPMF, rgbProbability_even_mode | Pass |
| Revised TYPE codes and likelihood | TypeCodebook.exists_separation, nearestType_exact_of_margin, typeProbability_sum, type_logits_equal_norm, typePMF | Pass |
| Positive residual-derived common width and normalized bank | residualDegrees_pos, residualVariance_* and residualScale_*; normalizedBank_energy; softplusGain_pos/one | Pass |
| Reader output interface without calibration assertions | ReaderSummary, rgbReaderSummary, typeReaderSummary; field inspection | Pass |
| Revised Gibbs equivalence at positive candidate-independent temperature | readerTemperature_pos, rgbReader_reconstruction_temperature | Pass |
| Typed segment round-trips and normalized dependent joint law | typedEmbedding_*_roundTrip, typedJoint_sum, typedJoint_type_marginal, typedJointPMF | Pass |
| Revised counts and explicit asymptotic work | structuredCoefficient_count, structured_512_count, structured_output_cost; scalar-work assumptions documented | Pass |
| BF16 representation separated from operation/prediction exactness | channelValue_bf16/dyadic; ideal-normal definitions inspected; storageCounter_wrong_even_decode | Pass |
| Zero residual/minimum width distinguished from correctness; multi-input limitation | wrongCode_zeroResidual, wrongCode_floorWidth, sharedTwoInput_not_injective | Pass |
| Actual main-result axiom audit and absence of holes/custom axioms | Diagnostics/AllAxioms; 115 distinct reports; scan of all 47 Lean sources | Pass |
| Reusable theorem map, corrections, dependency/build guidance and stages | PROPOSAL_MAP, THEOREM_OUTLINE, AUDIT, DEPENDENCIES, BUILD, VALIDATION and goal records | Pass |
| Incremental build structure preserves correctness | Specific leaf imports, separate diagnostics, thin root; focused builds, unchanged pins/kernel checks, no raised resource limits | Pass |

Consolidated command: `lake build TypeEmbeddings.Diagnostics.AllAxioms TypeEmbeddings`.
Actual result: success (2906 jobs), no warnings/errors; only standard foundational
axioms in the 115 reports. Raw evidence: `../goal-1/final-build.log`.

Scope is explicit rather than inferred from a green build. Mathematical extensions not
formalized here include Gaussian covariance/unbiased-residual statistics, generic dense
pseudoinverses, heap top-k, int64 serializers and mixture/autoregressive heads. They
require separately specified hypotheses/semantics. No greedy-TYPE joint maximization,
calibration, gradient correctness, model quality, FP32 execution or hardware speedup
is claimed. Source scripts/results and upstream README are absent. Fresh online bootstrap
has not been tested; the pinned local cached build is the observed reproducibility evidence.

The final explicit `lake build` invocation named all 47 project modules and passed
(2914 jobs), including optional diagnostics. Raw output: `../goal-1/final-module-build.log`.
This verifies delivered modules beyond the public-root import closure.

## Additional single-pass architecture

The first architecture and its historical completion evidence above are retained.
The subsequent user-authorized TEXT implementation adds ten public modules and two
diagnostics. Its exact claim map and completion boundaries are recorded in
[SINGLE_PASS_AUDIT.md](SINGLE_PASS_AUDIT.md); the new architecture is exported alongside
the first. It verifies encoder/readout/probability/conditional candidate mathematics,
not a trained transformer, Faiss implementation or finite-precision execution engine.
