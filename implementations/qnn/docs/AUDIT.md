# Source audit and correction log

This log distinguishes source reading findings from completed Lean results; see the paper map. Source
is the supplied Markdown; whether an error originated in typesetting or conversion
cannot be settled without the original pages. Never edit the source silently.

| ID | Source/finding | Provisional justified treatment | Status |
| --- | --- | --- | --- |
| A01 | Eq. (5) repeats j and omits i | Use sqrt(re² + imI² + imJ² + imK²). Products q·star(q) are real scalars embedded in quaternions; square root is of their real value. | Corrected identities proved in Algebra.lean |
| A02 | Eq. (7) assumes unit input vector | Unit conjugation applies to every pure vector, including zero. Require only a unit conjugating quaternion for a rotation. | Generalization proved in Geometry.lean |
| A03 | Eqs. (8)–(10) use angle 2α | Unit pure axis; fix ordered i,j,k orientation. Full formula includes the parallel component; orthogonal specialization needs a dot-product-zero hypothesis. | Full/orthogonal Rodrigues identities proved |
| A04 | Eq. (11) divides by ‖w‖ once | Tentatively read the denominator as the norm, yielding norm-scaled rotation for w≠0. Do not replace by squared norm: that would remove magnitude scaling and change the model. Confirm notation against original pages if available. | Norm reading retained explicitly; scaled-norm theorem proved |
| A05 | Eq. (11) has no zero-weight policy | Initially prove smoothness on the open domain where every weight is nonzero. Any total extension at zero must be explicitly labeled and separately analyzed; Lean's total inverse is not a differentiability justification. | Zero extension chosen; derivative theorems require nonzero weights |
| A06 | Eq. (11) threshold sign | Preserve subtraction, not addition; signals and thresholds are pure, weights are unrestricted real quaternions. | Forward model defined with subtraction |
| A07 | Sigmoid is componentwise | It preserves purity and constrains coordinate output to (0,1); arbitrary rotation equivariance is not supplied or presumed. | Purity, range and diagonal real derivative established |
| A08 | Error uses output index k and component index k | Separate output-neuron indices from axis labels. Displayed loss is for one output; finite-output/dataset sum or mean needs an explicit extension. | Single-output source loss; finite-output sum is an explicit extension |
| A09 | BP asserted, but only component gradient update displayed | Use real Fréchet derivatives and four real coordinate partials. Hidden-layer recurrences, denominator derivative, and threshold update are not provided. Derive them independently only after model/domain choices. | Network-wide weight gradients and simultaneous component updates proved |
| A10 | Constant η described as learning coefficient | Positivity is an assumption for any descent interpretation. An update definition alone proves neither finite-step decrease nor convergence; iterates may reach singular weights. | Learning claims unsupported without extra assumptions |
| A11 | §6 compares affine/color transformation capability | Each fixed-weight preactivation is affine on pure inputs; the sigmoid network is generally nonlinear. No restriction theorem or superiority claim for real networks follows. | Informal explanation only |
| A12 | §5 reports improved test PSNR | Preserve reported evidence and missing experimental details separately from geometry and training theorems. | Empirical, not proved |
| A13 | §5 calls the parameter counts approximately equal | Under the conventional dense interpretation, 48×12 + 12×48 = 1,152 real weights, whereas 4×(16×4 + 4×16) = 512 quaternion components. Both have 60 threshold components if thresholds are counted. Thus totals are 1,212 versus 572, not matched counts. Sparse/tied connectivity is not specified. | Source comparison qualified; not accepted as a theorem |

Decisions now made: mathlib real quaternions, the real-part-zero subspace,
Euclidean i,j,k coordinates, finite indexed layers and an inductive network
architecture, real Fréchet derivatives and Euclidean adjoints. Raw finite function
spaces are used for forward maps/differentials; gradient-facing signals use PiLp 2.
Unit conjugation is a linear isometry with cross-product/oriented-volume preservation;
SO(3) surjectivity or double-cover classification is not asserted.

The zero extension contributes zero when w=0. Source quotient agreement and
weight calculus are interpreted on nonzero weights; no differentiability theorem
at zero is claimed. Threshold training is not specified by the paper; the defined weight
training rule keeps thresholds fixed. Preservation of nonzero weights after a finite update is not
claimed; any iterative training theorem must handle its domain explicitly.

Independent reconstruction now proved: ordered sandwich product derivative,
inverse-norm derivative and correction term, component sigmoid Jacobian, squared
error gradient, adjoint chain rule, full-network input differential/reverse recursion,
and network-wide weight-gradient/update correspondence. These are not printed
BP equations. `docs/DERIVATION.md` explains the independently reconstructed rule;
`Network.trainStep_components` covers every addressed connection at every layer.
The source still does not settle batching, threshold learning, handling of weights
that reach zero, or the detailed experimental training implementation.
