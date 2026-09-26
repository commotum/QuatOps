# Source-to-library map (implemented results and remaining proposals)

Source: `../Quaternion_Recurrent_Neural_Networks.md` relative to this document.
Line numbers refer to the unchanged local Markdown, not PDF page numbers. Labels
are duplicated or absent in the transcription; section and line anchors take priority.
The table preserves the original proposed decomposition. Current verified
coverage and actual declaration names follow below; all are in namespace `Qrnn`.

| Source location | Kind | Proposed declarations / disposition |
|---|---|---|
| §3.1, lines 167–226; `eq:hamilton`, `eq:conjugate`, `eq:normalize` | Algebra identity / conditional normalization | `hamilton_components`, `leftBlock_apply`, `rightBlock_apply`, `normalize_norm` (nonzero) |
| §3.2, lines 228–248; motivations 107–118 | Structured linear architecture / counts | `quatMatVec`, `expand_apply`, `expand_mul`, `expand_conjTranspose`, `weight_parameter_count` |
| §3.3.1, lines 262–286; `eq:forward` | Architecture definitions | `splitActivation`, `QRNNParams`, `qrnnStep`, `qrnnRun`, `qrnnReadout` |
| §3.3.2, lines 288–349 | Gradient claims, update definitions | `affine_pullback`, `output_gradient`, `bptt_correct`, `recurrent_gradient`, `input_gradient`, `bias_gradient`; audit compact products |
| Appendix §6.3, lines 1135–1241 | Real components / output gradient | `output_gradient_components`; compare signs, right multiplication, activation factors |
| Appendix §6.3, lines 1243–1416 | Recurrent/input/bias derivatives | `bptt_correct`, `terminal_gradient`, `sequence_gradient`; audit cross-component sums, time factors and bias Jacobian |
| §3.4, lines 351–446; `eq:init`, `eq:weight`, `eq:var`, `eq:qinit`, Algorithm 1 | Initialization definitions / probability | `polar_norm_sq`, `quaternion_secondMoment`, `gaussian_norm_secondMoment`, `polar_uniform_secondMoment`; separate variance notions |
| Appendix §6.2, lines 924–1133 | Gaussian radius density / moments | `gaussian_norm_secondMoment`; optional `chi4_density` after probability API review; correct norm variance claim |
| §4.3 QLSTM, lines 548–584 | Gate/cell architecture | `QLSTMParams`, `qlstmStep`; clarify candidate affine operation and split tanh |
| §2 lines 107–118; §4.2 lines 525–540 | Weight and whole-model parameter counts | `weight_parameter_count`, `qrnn_parameter_count`, `qlstm_parameter_count`; architecture-specific assumptions required |
| Appendix §6.1.2, lines 908–922 | Arithmetic count / asymptotic claim | `hamilton_naive_cost`, `qrnn_step_cost`, `qlstm_step_cost`; declare scalar operation model and dimensions |
| Introduction; §4; Appendix §6.1.1 lines 865–906 | Empirical PER/WER, runtime, generalization | Record as experimental context only; no theorem |
| §3.4, §4.2, conclusion, appendix QBPTT regularization suggestion | Optimization / convergence / representation quality | Excluded unless separately specified and proved under adequate assumptions |

## Current verified declarations

| Source / class | Actual module and declarations | Status / hypotheses |
|---|---|---|
| §3.1 algebra and normalization | `Qrnn/Algebra.lean`: `hamilton_components`, `leftBlock_apply`, `rightBlock_apply`, `leftBlock_mul`, `rightBlock_mul`, `leftBlock_star`, `rightBlock_star`, `normalize_norm` | Proved. Norm-one needs nonzero input; right representation reverses composition order. |
| §3.2 matrix representation | `Algebra.lean`: `expand_apply`, `expand_mul`, `expand_conjTranspose`, `expand_injective`, `real_coordinate_count`, `matrix_mul_pair`, `matrix_weight_pair` | Proved for finite shapes, including zero dimensions; typed real expansion and Euclidean pairing. |
| §3.3.1 split functions | `Qrnn/ActivationCore.lean`: `splitActivation`; `Qrnn/Activation.lean`: `splitActivation_hasFDerivAt`, `splitDerivative_pair`, `splitDerivative_eq_hadamard` | Definition + real derivative proof; scalar differentiability at all preactivation coordinates. |
| §3.3.1 recurrence | `Qrnn/Forward.lean`: `QRNNParams`, `qrnnStep`, `qrnnReadout`, `qrnnRun`, `qrnnFiniteRun`, `qrnnRun_prefix`, `qrnnStep_expand`, `qrnnRun_expand` | Architecture definitions + real-representation equivalence; supplied initial state, input k drives state k+1. |
| Local derivatives underlying §3.3.2 / §6.3 | `Qrnn/Derivatives.lean`: `matVec_hasFDerivAt`, `qrnnStep_state_hasFDerivAt`, `recurrentWeight_hasFDerivAt`, `inputWeight_hasFDerivAt`, `bias_hasFDerivAt`, `layerWeight_hasFDerivAt`, `readoutDerivative_pair`, `qrnnStateDerivative_pair` | Proved local real derivatives/pullbacks. Held-fixed states are explicit in partial-weight lemmas. Shared-parameter accumulation is proved in QRNNGradients. |
| Output MSE gradient (§3.3.2 and §6.3 output weights) | `Qrnn/Loss.lean`: `halfSquaredLoss_hasFDerivAt`, `outputLoss_hasFDerivAt`, `output_gradient` | Proved with explicit 1/2 loss scaling and differentiable split β; output-gradient pairing is the Euclidean identification of the proved differential. |
| §4.3 QLSTM | `Forward.lean`: `GateParams`, `QLSTMParams`, `gatePreact`, `vectorHadamard`, `qlstmStep` | Definitions only; documented Hamilton candidate interpretation. No QLSTM gradient or performance theorem. |
| Reconstructed §3.3.2 / §6.3 BPTT | `Qrnn/BPTT.lean`: `unroll_hasFDerivAt`, `bptt_correct`, `terminalLoss_hasFDerivAt`, `sequenceLoss_hasFDerivAt`; `Qrnn/QRNNBPTT.lean`: `qrnnStep_joint_hasFDerivAt`, `qrnnRun_hasFDerivAt`, `qrnnBptt_correct`, `qrnnTerminalStateLoss_hasFDerivAt` | Proved generic real chain rule and concrete QRNN state-loss bridge, with fixed initial state and scalar differentiability hypotheses. These generic/state-only results are supplemented by the full output-loss theorems below. |
| Corrected compact/appendix gradients (§3.3.2 / §6.3) | `Qrnn/QRNNGradients.lean`: `qrnnJointDerivative_apply`, `qrnnParameterPartial_apply`, `qrnnStatePartial_apply`, `qrnnParameterDerivative_pair`, `quaternionBpttGradient_correct`, `qrnnTerminalLoss_hasFDerivAt`, `qrnnTerminalGradient_correct`, `qrnnSequenceLoss_hasFDerivAt`, `qrnnSequenceGradient_correct`, `qrnnTerminalGradient_output` | Proved for actual shared recurrent/input/output/bias parameters, with Euclidean four-component pairing and scalar differentiability at visited preactivations. Loss scaling is 1/2; fixed initial state; arbitrary finite time sums. |
| Invalid literal error products (§3.3.2, lines 332–344) | `Qrnn/BPTTAudit.lean`: `propagated_error_product_counterexample` | Proved diagnostic: correct shared bias accumulation 4 versus literal compact expression 6. This refutes the error-vector-product reading, not legitimate Jacobian composition. |
| Polar algebra / §3.4 and §6.2 | `Qrnn/InitializationCore.lean`: `polarWeight`, `sampledDirection`, `polar_norm_sq`, `polar_norm`, `sampled_polar_norm_sq`, `gaussianScale_secondMoment`, `uniformAmplitudeBound_secondMoment` | Proved with pure unit direction / nonzero sample and positive fan assumptions. Signed amplitude has norm equal to its absolute value. |
| Correct variance notions / §3.4, §6.2 | `Qrnn/InitializationMoments.lean`: `quaternionSecondMoment_components`, `quaternionVariance_eq`, `quaternionVariance_of_centered`, `quaternionNorm_mean_pos`, `quaternionNorm_variance_lt_secondMoment` | Proved with explicit real integrability/L2 hypotheses. Covariance trace is not scalar norm variance; a nontrivial norm has positive mean. |
| Gaussian model / appendix §6.2 | `Qrnn/InitializationGaussian.lean`: `gaussianQuaternion_secondMoment`, `gaussianQuaternion_variance`, `gaussianQuaternion_sigma_secondMoment` | Actual N(0,v) component laws give second moment / covariance trace 4v; independence is unnecessary for these results. Chi-density/law not proved. |
| Actual bounded polar sampler / Algorithm 1 | `Qrnn/InitializationUniform.lean`: `uniformPolar_secondMoment`, `uniformPolar_norm_mean`, `uniformPolar_norm_variance`, `uniformPolar_quaternionVariance`, `imaginarySample_nonzero_ae`, `uniformPolar_paperScale_secondMoment`, `correctedUniformPolar_secondMoment` | Uniform signed amplitude gives σ²/3 second moment, σ/2 mean norm, σ²/12 norm variance. Covariance trace σ²/3 requires amplitude-factor independence; corrected target bound sqrt(3 target). |
| Zero / direction boundaries | `Qrnn/InitializationAudit.lean`: `zero_direction_polar_counterexample`, `sampledDirection_imI_nonnegative` | Diagnostic proofs, separate from the public API. Positive-octant normalization alone does not justify isotropy. |
| All completed main results | `Qrnn/AxiomAudit.lean`; `goal-1/axioms.txt` | Observed axioms: standard Lean foundations only; 76 main results audited; diagnostic leaf excluded from public imports. |

QLSTM real-expansion theorem, parameter counts and cost model remain unfinished.
The chi-density/law derivation is not formalized; Gaussian moment results use
actual Gaussian component laws instead. No unsupported chi law is assumed.

Missing `layer.png` and referenced tables mean the local source alone does not
fully specify experiment architectures or reproduce their totals.
