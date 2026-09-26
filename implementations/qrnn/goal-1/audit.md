# Preliminary audit and correction log

Status: algebra and local real derivatives are implemented and compiled. The
original table preserves the preliminary audit targets; the verified dispositions
below distinguish established corrections from remaining work.
Do not import the paper formulas as axioms.

| ID | Source | Preliminary concern | Proposed handling / open hypothesis |
|---|---|---|---|
| A01 | §3.1 normalization | Division by norm omits zero case. | Require nonzero or explicitly define a fallback; distinguish total definition from unit-norm theorem. |
| A02 | §3.1 `Q_mat`; appendix `eq:hconj` | The appendix derivative matrix is associated with right multiplication by the conjugated input, whereas the opening block is left multiplication. | Prove both component representations independently; do not identify them as the same matrix. |
| A03 | §3.2 | Real dimensions N,M and quaternion counts are mixed. | Use quaternion shape m×n with real expansion (4m)×(4n); document component ordering. |
| A04 | §3.3.2 output update; appendix output weights | Residual is named a weight derivative in the main text; appendix includes the input conjugate. Generic beta derivative is missing from those formulas. | Define output-preactivation cotangent first; derive entrywise outer-product gradient. Specify half-squared error or scaling, and beta=identity for residual-only rule. |
| A05 | §3.3.2 delta terminal case | Output activation derivative appears after output-weight multiplication, and hidden activation derivative seems absent. | Reconstruct pullback composition in the exact order: output activation, output affine adjoint, hidden activation. Need differentiability at preactivations. |
| A06 | Both QBPTT sections | Products of delta vectors mix propagated errors with Jacobian operators; ranges differ m versus m+1, appendix factors use h_(t-1),x_t instead of varying m. | Define terminal-loss adjoints by reverse recurrence, then sum local shared-parameter contributions. An explicit ordered Jacobian product is a separate theorem. |
| A07 | Appendix hidden/input/bias components | Repeated component labels, cross-component chains omitted or inconsistent, bias Jacobian described as a matrix of ones. | Rebuild full real Jacobians; additive bias Jacobian should be identity. Audit every sign and index against Hamilton formulas. |
| A08 | Both QBPTT sections | Matrix conjugation/transposition, tensor/outer-product shapes, and first timestep h_(-1) unspecified. | Use conjugate transpose for affine adjoints; entrywise gradients; initial h₀ and steps 1..T as tentative convention. Initial state independent of parameters unless extra term is included. |
| A09 | §3.4 and appendix §6.2 | Symmetry of W is used to infer E(norm W)=0. Radius is nonnegative; centered-vector variance and scalar norm variance differ. | Define E(norm(W−E W)²) separately from Var(norm W); finite second moments explicit. No assertion that the norm has zero mean. |
| A10 | Algorithm 1 versus appendix §6.2 | Bounded uniform polar amplitude is not the independent Gaussian component model used for chi radius. | Specify both probability laws separately. Proposed targets: Gaussian second moment 4σ²; unit-direction polar norm²=φ² and uniform φ second moment σ²/3. These are future proofs, not established results here. |
| A11 | Algorithm 1 | Normalized positive-octant uniform direction is not uniform spherical direction; zero direction needs handling; sampling independence implicit. | Record direction distribution, zero-event/fallback, angle/amplitude law and joint assumptions. Do not claim isotropic components without proof. |
| A12 | `eq:qinit`, polar form | Fan-in units unclear; signed φ is not a nonnegative radius; scaling heuristic may not match actual sampler moments. | State quaternion versus real fan counts, moments intended per component or total, positive scale; distinguish signed polar parametrization from radius and convergence claims. |
| A13 | QLSTM c_t equation | Candidate term writes W_c x_t and R_c h_(t-1) without Hamilton symbol; tanh and gate activation convention need precision. | Propose Hamilton affine candidate with split tanh, but label as interpretation; gates are explicitly componentwise products. Define initial cell/hidden state. |
| A14 | Counts / complexity | Factor four applies to weight degrees of freedom at equal real feature size, not uniformly to biases, readouts or whole models. 28 operations counts naive scalar Hamilton arithmetic. | Count independent real parameters; declare all layers/head/biases. Separate 16 scalar multiplications and 12 additions/subtractions from accumulation and nonlinearities. O(n²) requires specified input/output scaling and horizon. |
| A15 | Experiments/conclusion | Better recognition, regularization, annealed convergence and runtime are empirical or heuristic. | Exclude from verified core; no formal consequence asserted. Softmax couples coordinates and is not a scalar split activation. Model as a general real head if needed. |

When a correction is established, append exact real statement, assumptions,
proof or counterexample declaration, source anchor, and effect on dependent claims.
Unsupported source claims remain visible instead of being silently dropped.

## Verified dispositions (2026-09-25)

- A01: `normalize_norm` requires `q ≠ 0`; `normalize_zero` establishes the total
  fallback at zero. No unit-norm assertion is made for zero.
- A02: `leftBlock_apply` and `rightBlock_apply` distinguish both ordered actions;
  `rightBlock_star` explains the appendix weight-pullback matrix, and
  `weight_mul_pair` establishes `g * star x` as its Euclidean cotangent action.
- A03: `expand_apply`, `expand_mul`, `expand_injective`, and
  `real_coordinate_count` establish shape and parameter preservation. Dimensions
  are typed as `(Fin m × Fin 4)` by `(Fin n × Fin 4)`.
- A04: `outputLoss_hasFDerivAt` and `output_gradient` prove the output-weight
  gradient for explicit half-squared error and differentiable split β. The
  preactivation cotangent is the split derivative acting on the residual, and
  `weightOuter` multiplies each resulting output cotangent on the right by the
  conjugated hidden input. A residual is not itself a matrix-weight derivative.
- A05: `readoutDerivative_pair` and `qrnnStateDerivative_pair` establish the
  correct local composition order with activation derivatives at preactivations.
  Full recurrent/terminal composition is the ongoing stage 3 proof.
- A07 (bias part): `bias_hasFDerivAt` has the split derivative as its Jacobian,
  because the additive-bias map has identity derivative before activation. The
  appendix's matrix-of-ones description is not adopted.
- A08 (local part): `matrix_mul_pair` proves conjugate transpose for the matrix
  pullback; `qrnnRun_prefix`, `qrnnFiniteRun` and `qrnnRun_expand` give explicit
  initial state and finite-horizon dependence. Input k drives state k+1, avoiding
  a negative state index. Parameter accumulation is not yet fully proved.
- A13: `qlstmStep` defines the gate/cell architecture with explicitly separate
  Hamilton affine maps and componentwise gate products. It interprets the
  candidate's missing multiplication symbols consistently with the other gates.
  This is a documented architecture interpretation, not a theorem that the paper
  uniquely specifies it. Scalar gate/tanh functions remain explicit arguments.

A06, the rest of A07/A08, initialization A09–A12, whole-model A14 counts, and
stronger probability distribution claims remain open. A15 empirical and
unsupported convergence/regularization assertions remain outside the verified core.

## Axiom audit status

`Qrnn/AxiomAudit.lean` uses `#print axioms` for the completed main results;
`goal-1/axioms.txt` records observed kernel output. So far those results depend
only on `propext`, `Classical.choice`, and `Quot.sound`. No project-specific axiom
or `sorryAx` appears. Update the audit when new main results are added. Proposed
claims in planning documents are not Lean declarations or imported assumptions.

## State-loss BPTT verification and build boundaries (2026-09-25)

`bptt_correct` proves reverse ordered Jacobian composition equals the forward
sensitivity; `terminalLoss_hasFDerivAt` and `sequenceLoss_hasFDerivAt` connect it
to actual real loss derivatives. `qrnnStep_joint_hasFDerivAt` proves joint QRNN
differentiability under componentwise scalar hypotheses;
`qrnnRun_hasFDerivAt` and `qrnnTerminalStateLoss_hasFDerivAt` instantiate the
chain rule and reverse derivative for the actual QRNN recurrence. The fixed
initial state's parameter derivative is zero, including horizon zero.
This advances A05–A08, but explicit compact accumulated parameter gradients and
a jointly variable output head remain open. These results do not endorse the
paper's products of error vectors or its ambiguous appendix indexing.

The import refactor preserves mathematical statements and proofs. The public
entry point excludes diagnostic AxiomAudit; its explicit kernel check still
covers all 35 reported results with standard foundations only. Details of
focused builds and timing observations are in 3-bptt.md.

## Completed QBPTT reconstruction (2026-09-25)

A05–A08 now have actual real-calculus correctness theorems in QRNNGradients.
For a terminal output loss at state time T, write h₀ for the fixed initial state,
zₖ = R hₖ + I xₖ + b, hₖ₊₁ = split f(zₖ), and e = readout(h_T) − y.
Set δ_out = Dβ e and g_T = Oᴴ δ_out. For k = T−1,…,0, compute
δₖ = Dfₖ gₖ₊₁ and gₖ = Rᴴ δₖ. Contributions are
(R: δₖ hₖ*, I: δₖ xₖ*, b: δₖ); sum over visited steps. The direct
output contribution is δ_out h_T*. Here outer products are entrywise Hamilton
products with the conjugated input on the right; Df and Dβ are diagonal real
split derivatives, equivalent to Hadamard products. They are evaluated at
preactivations. Every matrix pullback uses conjugate transpose.

`qrnnTerminalGradient_correct` proves pairing with this four-family gradient is
the actual real differential on every parameter direction.
`qrnnSequenceGradient_correct` proves the same for finite sums of terminal
output losses. A time-zero term can differentiate through its variable output
weights, but not through the fixed initial hidden state.

The compact source lines 332–344 and appendix lines 1353–1414 are not adopted
as equivalent specifications: their product ranges differ, their error-vector
products duplicate already propagated errors, appendix recurrent/input factors
use terminal-time data instead of each local step's data, and the terminal
hidden activation derivative is absent. Cross-component mixing comes from the
full real Jacobian, not products of single component derivatives. The printed
conjugated matrices must be transposed as well when non-scalar shapes are used.
The appendix's bias Jacobian is identity before activation, not a matrix of ones.
`propagated_error_product_counterexample` verifies bias accumulation 4 versus
literal δ₀δ₁+δ₁ = 6 with δ₀=δ₁=2 in a two-step scalar linear subcase. This is
kept in a diagnostic leaf, separate from the reusable corrected recurrence.

The prior paragraphs about stage 3 being open describe earlier intermediate
coverage. A06–A08 reconstruction is now complete; initialization A09–A12 and
counts A14 remain next. No empirical/optimization claims have been promoted.

## Initialization corrections verified (2026-09-26)

A09–A12 have corrected moment results. `quaternionVariance` is the sum of four
real component variances, and `quaternionVariance_eq` proves covariance trace =
E||W||² − sum of squared component means. `quaternionNorm_mean_pos` proves that
E||W|| > 0 whenever the norm is integrable and W is not almost surely zero.
`quaternionNorm_variance_lt_secondMoment` then shows norm variance is strictly
smaller than E||W||² under finite second moments. This corrects the paper's
symmetry argument; symmetric W does not center its nonnegative norm.

`gaussianQuaternion_sigma_secondMoment` derives 4σ² from actual centered real
Gaussian component laws, including integrability. The same is covariance trace
with centered components. No chi density or norm-variance identity is assumed.
The appendix's density/law derivation and closed-form Gaussian norm mean remain
outside the verified surface; the moment calculation has a rigorous component
law proof instead.

For the printed continuous uniform amplitude φ in [-σ,σ] and pure unit
imaginary direction, polar norm equals |φ|. `uniformPolar_secondMoment`,
`uniformPolar_norm_mean` and `uniformPolar_norm_variance` prove σ²/3, σ/2 and
σ²/12 respectively. These norm facts require no angle/direction independence.
`uniformPolar_quaternionVariance` proves centered covariance trace σ²/3 when
φ is independent of each measurable angular/directional coordinate factor.
Thus the printed σ = 1/sqrt(2 fan) gives 1/(6 fan), not its intended 2/fan.
`uniformAmplitudeBound` and `correctedUniformPolar_secondMoment` use
sqrt(3 target), or sqrt(6/fan) for that target. This is moment calibration,
not an optimization or convergence theorem. Fan counts are still explicit
architecture conventions, not silently assumed real-component counts.

`imaginarySample_nonzero_ae` proves a single continuous uniform positive sample
coordinate excludes zero direction almost surely; independence of x,y,z is not
needed. For a deterministic zero sample, the total normalization fallback is
zero and `zero_direction_polar_counterexample` refutes the unqualified unit-norm
claim. `sampledDirection_imI_nonnegative` records the positive-octant support
constraint; sampling a normalized positive cube vector is not a specified
uniform full-sphere law. No isotropy or chi law is asserted for the actual sampler.
