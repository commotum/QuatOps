# Preliminary audit and correction log

Status: source inspection only. No substantive formal audit, Lean implementation,
proof, or counterexample has been completed. Entries are targets for verification;
proposed reconstructions must be justified by real component calculus later.
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

## Axiom audit status

Project Lean source currently consists only of imports/comments: no project
axioms, definitions or theorems, and no `sorry`. There are no main results to audit.
An import smoke build does not constitute a mathematical axiom audit. When results
exist, record `#print axioms Qrnn.<mainResult>` output per result. Ordinary Lean
foundational dependencies (e.g. classical choice/propositional extensionality)
are to be reported; project-specific assumptions belong in theorem hypotheses,
not unexplained axioms. Any dependency on `sorryAx` fails completion.
