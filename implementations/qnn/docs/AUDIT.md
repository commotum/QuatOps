# Initial source audit and correction log

This is a scaffold-level reading audit, not completed formal verification. Source
is the supplied Markdown; whether an error originated in typesetting or conversion
cannot be settled without the original pages. Never edit the source silently.

| ID | Source/finding | Provisional justified treatment | Status |
| --- | --- | --- | --- |
| A01 | Eq. (5) repeats j and omits i | Use sqrt(re² + imI² + imJ² + imK²). Products q·star(q) are real scalars embedded in quaternions; square root is of their real value. | Correction identified; formal proof pending |
| A02 | Eq. (7) assumes unit input vector | Unit conjugation applies to every pure vector, including zero. Require only a unit conjugating quaternion for a rotation. | Generalization proposed |
| A03 | Eqs. (8)–(10) use angle 2α | Unit pure axis; fix ordered i,j,k orientation. Full formula includes the parallel component; orthogonal specialization needs a dot-product-zero hypothesis. | Proof and sign audit pending |
| A04 | Eq. (11) divides by ‖w‖ once | Tentatively read the denominator as the norm, yielding norm-scaled rotation for w≠0. Do not replace by squared norm: that would remove magnitude scaling and change the model. Confirm notation against original pages if available. | Source ambiguity open |
| A05 | Eq. (11) has no zero-weight policy | Initially prove smoothness on the open domain where every weight is nonzero. Any total extension at zero must be explicitly labeled and separately analyzed; Lean's total inverse is not a differentiability justification. | Design decision open |
| A06 | Eq. (11) threshold sign | Preserve subtraction, not addition; signals and thresholds are pure, weights are unrestricted real quaternions. | Model definition pending |
| A07 | Sigmoid is componentwise | It preserves purity and constrains coordinate output to (0,1); arbitrary rotation equivariance is not supplied or presumed. | Basic results planned |
| A08 | Error uses output index k and component index k | Separate output-neuron indices from axis labels. Displayed loss is for one output; finite-output/dataset sum or mean needs an explicit extension. | Aggregation open |
| A09 | BP asserted, but only component gradient update displayed | Use real Fréchet derivatives and four real coordinate partials. Hidden-layer recurrences, denominator derivative, and threshold update are not provided. Derive them independently only after model/domain choices. | Major reconstruction pending |
| A10 | Constant η described as learning coefficient | Positivity is an assumption for any descent interpretation. An update definition alone proves neither finite-step decrease nor convergence; iterates may reach singular weights. | Learning claims unsupported without extra assumptions |
| A11 | §6 compares affine/color transformation capability | Each fixed-weight preactivation is affine on pure inputs; the sigmoid network is generally nonlinear. No restriction theorem or superiority claim for real networks follows. | Informal explanation only |
| A12 | §5 reports improved test PSNR | Preserve reported evidence and missing experimental details separately from geometry and training theorems. | Empirical, not proved |

Additional unresolved choices: pure subspace versus coordinate-first implementation;
finite index types and layer architecture; unit conjugation representation as a
linear isometry versus an explicit special orthogonal map; minimal scope of
rotation representation results; objective metric and adjoint conventions; optional
threshold training; preservation of the nonzero domain after updates. Full coverage
of SO(3) and its double cover is optional unless needed for paper claims.

No gradients, BP recurrences or source identities have been proved in this scaffold.
