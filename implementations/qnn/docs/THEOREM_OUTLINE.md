# Proposed declaration outline

This is the historical scaffold outline. Actual declarations and current completion
status are in `PAPER_MAP.md`; differences in names reflect implementation choices.
No theorem placeholders or proof holes are used in source files.

| Proposed area/name | Intended statement and essential assumptions |
| --- | --- |
| `Algebra.hamilton_rules` | Ordered products of standard quaternion basis elements; exhibit ij≠ji |
| `Algebra.conjugate_mul` | star(a·b)=star(b)·star(a), involution and coordinate signs |
| `Algebra.norm_sq_components` | Correct four-term norm square; both q·star(q) and star(q)·q equal its real embedding |
| `Pure.toEuclidean` | Real linear isometry between pure subspace and Euclidean 3-space |
| `Pure.mul_dot_cross` | Product of pure u,v has real part −dot(u,v) and vector part cross(u,v) |
| `Geometry.conjugation_preserves_pure` | a·v·star(a) is pure for pure v, any a |
| `Geometry.unitConjugation` | For norm a=1, induced real linear isometry on pure space |
| `Geometry.axisAngle_unit` | cos α + sin α • u is unit for pure unit u, any real α |
| `Geometry.rodrigues` | cos(2α) v + sin(2α)(u×v) + (1−cos(2α))dot(u,v)u for pure unit axis u |
| `Geometry.rodrigues_orthogonal` | Eq. (9) when dot(u,v)=0; no unit-v requirement |
| `Geometry.rotation_orientation` | Unit conjugation preserves orientation; justify representation as spatial rotation |
| `Neuron.weightAction` | Nonzero-weight action (1/‖w‖) • (w·x·star(w)); zero handling explicit if added |
| `Neuron.weightAction_norm` | For w≠0, output norm = ‖w‖·‖x‖; distinguish scaled rotation from unit rotation |
| `Neuron.preactivation` | Finite sum of weight actions minus pure threshold; purity/affineness in inputs |
| `Activation.componentSigmoid` | Apply sigmoid to i,j,k only; purity, coordinate range, real derivative |
| `Network.forward` | Composition of finite layers with explicit dimensions and parameter domains |
| `Loss.singleOutput` | ½‖y−d‖² for pure y,d; component expression, nonnegative, zero iff equality |
| `Loss.aggregate` | Explicitly chosen finite-output/data sum or mean as a model extension |
| `Calculus.weightAction_hasFDerivAt` | Real derivative at nonzero w, including conjugate and norm-denominator terms with order preserved |
| `Calculus.forward_differentiable` | Finite network smooth/differentiable on nonzero-weight domain |
| `Training.loss_gradient_components` | Four coordinate partials agree with real gradient; metric and coordinates fixed |
| `Training.backprop_chain_rule` | Correct output/hidden-layer adjoint recursion for a fully specified finite network |
| `Training.gradientStep` | Parameter update by −η times gradient; componentwise agreement with source update |

The normalized weight differential, input reverse recursion and connection gradient
now have proofs; complete network weight-gradient assembly remains an investigative target. Their
completion requires independent derivation and proof, not an assertion that they
were printed in the paper. Optional threshold updates are also an extension.
No convergence, global loss decrease, improved learning/generalization or PSNR
comparison is included in the proposed theorem set. Any future local descent
result must state its separate smoothness, step-size and domain assumptions.

When main results exist, collect actual `#print axioms` output by declaration and
explain standard foundational dependencies. Do not replace an axiom audit with a
text search alone, and do not require an empty axiom list for ordinary real analysis.
