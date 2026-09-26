# Proposed theorem outline — statements only in prose

All names are tentative future declarations, not stub Lean theorems. No proofs,
network definitions, or axiom assumptions are added by this outline.

| Proposed declaration | Strongest intended statement / necessary conditions |
|---|---|
| `hamilton_components` | Multiplication in `Quaternion ℝ` has the paper's four ordered Hamilton components. |
| `leftBlock_apply`, `rightBlock_apply` | Real coordinates of q*x and x*q equal application of their respective 4×4 matrices. |
| `leftBlock_mul`, `leftBlock_transpose` | L(p*q)=L(p)L(q); L(conj q)=transpose L(q). Right representation composition has the corresponding reversed order. |
| `expand_apply`, `expand_mul` | Quaternion m×n matrix action/product agrees with real block expansion, with all intermediate dimensions explicit. |
| `expand_conjTranspose`, `affine_pullback` | Conjugate transpose is the Euclidean real adjoint; local cotangent g pulls back to Wᴴg. Weight entry cotangent is g_i*conj(x_j), proved from real components. |
| `normalize_norm` | Normalizing a nonzero quaternion yields norm one. No nonzero conclusion at zero. |
| `splitActivation_hasFDerivAt` | Scalar differentiability at all four coordinates yields a diagonal real derivative with the four scalar derivatives. |
| `qrnnRun_expand` | Quaternion recurrence and structured real recurrence agree at every finite timestep, with same initial state and inputs. Architecture equivalence only. |
| `qrnnStep_hasFDerivAt` | Forward derivative with respect to states and parameters follows from local derivatives, given differentiability at the actual preactivations. |
| `output_gradient` | For half squared error and differentiable readout, the output weight gradient uses the preactivation cotangent times conjugated hidden-state components; residual-only case requires identity readout (or separately justified loss/readout cancellation). |
| `bptt_correct` | Finite reverse adjoint recursion equals the real differential of the unrolled terminal or summed loss under explicit smoothness assumptions. |
| `recurrent_gradient`, `input_gradient`, `bias_gradient` | Shared-parameter gradients sum local contributions over the correct timesteps; recurrent factors use preceding state, input factors use that step's input; bias contribution is the preactivation cotangent. |
| `terminal_gradient`, `sequence_gradient` | Single-time loss contributions propagate only to preceding times; finite sum of per-time losses differentiates to a sum of gradients. Empty horizon and fixed initial-state boundary explicit. |
| `polar_norm_sq` | For unit imaginary direction, squared norm of the trigonometric polar weight is φ²; signed amplitude allowed. |
| `quaternion_secondMoment` | Squared quaternion norm moment is the sum of its four component second moments; centered Euclidean variance subtracts norm² of the mean, assuming finite moments. |
| `gaussian_norm_secondMoment` | Four zero-mean components with second moment σ² have total second moment 4σ²; independence only needed for stronger Gaussian/chi distribution claims. |
| `polar_uniform_secondMoment` | Explicit uniform amplitude on [−σ,σ], σ>0, with unit direction gives norm second moment σ²/3. A centered vector-variance conclusion needs zero vector mean. |
| `chi4_density` (optional) | Norm of four independent centered Gaussian components with σ>0 has the stated density on nonnegative radii; never equate its variance with its second moment without subtracting its mean squared. |
| `qlstmStep_expand` | Chosen explicit QLSTM gates/cell update agree with structured real equations; Hamilton candidate-affine interpretation and componentwise gate products documented. |
| `weight_parameter_count` | An m×n quaternion matrix has 4mn independent real coordinates; arbitrary real (4m)×(4n) matrix has 16mn. Biases counted separately. |
| `qrnn_parameter_count` | For quaternion input d, hidden h, output o, printed single-layer QRNN has 4(h²+hd+oh+h) real parameters. Optional output bias adds 4o. Whole-model variants specified separately. |
| `qlstm_parameter_count` | Four independent gates/candidate affine maps with h hidden and d input units have 16(hd+h²+h) real parameters, excluding head/directions/layers. |
| `hamilton_naive_cost` | Standard component algorithm uses 16 scalar multiplications and 12 additions/subtractions, under unit arithmetic cost. No optimality or elapsed-time claim. |
| `qrnn_step_cost`, `qlstm_step_cost` | Exact counts for a declared dense evaluation algorithm including accumulations, biases and nonlinearities; O(h²) only under stated input/output scaling and fixed gate count, per timestep. |

Acceptance at implementation: actual statements compile, document hypotheses and
claim class, link to source/audit IDs, and have recorded main-result axiom output.
Count identities describe free coordinates, not unrestricted expressive power;
initialization moments alone prove no optimization or recognition advantage.
