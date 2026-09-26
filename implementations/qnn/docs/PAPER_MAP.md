# Current paper map

Source: `../Quaternion_Neural_Network_and_Its_Application.md`, supplied Markdown
transcription by Isokawa, Kusakabe, Matsui and Peper. Original pages/figures are
not available in this folder. Declaration names below are actual compiled
names unless explicitly marked pending. All project names have prefix `QNN`.

| Source | Kind | Actual coverage | Status |
| --- | --- | --- | --- |
| §2 (1) | Algebra/coordinates | Mathlib `Quaternion ℝ`, `Quaternion.linearIsometryEquivTuple` | Reused |
| §2 (2)–(3) | Exact identities | `hamilton_rules`, `multiplication_not_commutative` | Proved |
| §2 (4) | Conjugation | Mathlib `star`; `conjugate_mul`, `conjugate_involutive` | Reused/proved |
| §2 (5) | Corrected norm | `norm_sq_components`, `norm_components`, `mul_conjugate`, `conjugate_mul_self` | Proved; repeated component corrected |
| §2 (6) | Pure vectors | `pureSubspace`, `pureEuclidean`, `pure_mul`, `pure_inner` | Defined/proved |
| §3 (7) | Geometry | `unitConjugation`, `unit_conjugate_cross`, `unit_conjugate_oriented_volume` | Proved for arbitrary pure inputs |
| §3 (8) | Axis-angle | `axisAngle`, `axisAngle_unit` | Defined/proved; arbitrary real angle |
| §3 (9) | Orthogonal rotation | `rodrigues_orthogonal` | Proved with unit axis and dot=0 |
| §3 (10) | Full rotation | `rodrigues` | Proved in full Rodrigues form including parallel component |
| §4 (11) | Forward definition | `weightAction`, `weightAction_formula`, `preactivation`, `inputLinear` | Defined; zero extension explicit |
| §4 (11) normalization | Exact scaling | `weightAction_norm` | Proved on nonzero weights; magnitude scaling retained |
| §4 (12)–(14) | Component activation | `activation`, `activation_range`, `activation_hasFDerivAt`, `activationDerivative_coordinate`, `neuron` | Defined/proved in fixed i,j,k frame |
| §4 layered model | Architecture | `Layer`, `Network`, `Network.forward` | Finite architecture defined |
| §4 unnumbered error | Objective | `loss`, `loss_components`, `loss_nonneg`, `loss_eq_zero`, `loss_hasGradientAt` | Source one-output loss defined/proved |
| Multiple outputs | Explicit extension | `outputLoss`, `outputLoss_nonneg` | Sum convention, not attributed to source |
| §4 weight differentiation | Independent derivation | `weightAction_hasFDerivAt`, `weightDerivative_apply`, `pureWeight_hasFDerivAt` | Proved over ℝ, nonzero weights |
| §4 update equations | Real gradient update | `gradientStep`, `componentPartial_eq_gradient`, `quaternion_update_eq_partials`, `connection_update_components` | Defined/proved; no descent theorem |
| §4 BP assertion | Reverse derivative core | `Network.input_hasFDerivAt`, `Network.pullback_eq`, `Network.pullback_hasFDerivAt`, `gradient_chain` | Recursive input differential propagation proved |
| §4 BP weight learning | Connection rule | `neuron_eq_connection`, `connection_loss_gradient`, `connection_backprop` | Concrete one-connection gradient proved; full network weight-gradient assembly pending |
| §1/§6 learning/geometric superiority | Informal/unsupported | See audit A10–A12 | No mathematical superiority/convergence theorem |
| §5 Tables 1–2 | Empirical evidence | Reported PSNR below | Documentation only |
| §6 theoretical explanation | Speculation/future work | Lack of detailed explanation recorded | Not a theorem |

`QNN/AxiomAudit.lean` and `AXIOMS.txt` contain the actual current axiom audit of
main results. Hypotheses such as unit axis, orthogonality, nonzero weight, and a
proved downstream derivative must not be dropped from the coverage claims.
SO(3) surjectivity/double-cover classification is not claimed; unit conjugation
is justified by linear isometry, cross-product and oriented-volume preservation,
composition, and the doubled-angle formula.

Table 1 total PSNR: real 26.68 dB, quaternion 26.67 dB. Table 2 total PSNR:
real 18.04 dB, quaternion 21.99 dB. These are source-reported measurements, not
formal consequences. Referenced images, seeds and full training implementation
are absent. No experimental reproduction or independent PSNR verification was done.
