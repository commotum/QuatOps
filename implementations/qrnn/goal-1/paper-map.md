# Source-to-library map (proposed, not implemented)

Source: `../Quaternion_Recurrent_Neural_Networks.md` relative to this document.
Line numbers refer to the unchanged local Markdown, not PDF page numbers. Labels
are duplicated or absent in the transcription; section and line anchors take priority.
All declaration names below are proposals in the future `Qrnn` namespace.

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

No listed declaration exists yet. At implementation, replace proposals with actual
module/name links, hypotheses, verification status and `#print axioms` results.
Missing `layer.png` and referenced tables mean the local source alone does not
fully specify experiment architectures or reproduce their totals.
