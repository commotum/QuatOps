# 4-initialization

## Current Facts

Stages 1–3 compile; full gradients and the literal-error-product counterexample
are verified. The paper initialization uses a signed uniform amplitude in
[-σ,σ], a uniform angle, and a normalized positive-octant imaginary direction.
Its appendix instead assumes four independent centered Gaussian components.
Mathlib supplies quaternion normSq, real integration, Gaussian laws and moments,
and ordinary scalar variance. InitializationCore, InitializationMoments, InitializationGaussian and
InitializationUniform now compile, with diagnostics in InitializationAudit.

## Updated Assumptions

Use explicitly specified random variables and laws. A nonzero sampled direction
is needed for unit normalization; a zero fallback alone does not preserve the
polar norm identity. Independence is unnecessary for the sum of component
second moments. Symmetry centers a quaternion vector but not its nonnegative norm.
No optimization guarantee follows from selecting a variance scale.

## Big Picture Objective

Verify polar norm algebra and the variance/second-moment calculation for stated
models. Reconcile Gaussian moments with the paper's actual bounded sampler;
prove correct scale formulas with positive fan hypotheses. Do not import an
unproved chi law or imply that the bounded sampler is Gaussian.

## Detailed Implementation Plan

Create InitializationCore for deterministic polar definitions and norm proofs.
Create InitializationMoments for component integrals and variance identities;
keep Gaussian and bounded-uniform law adapters in separate proof leaves.
Use mathlib real Gaussian laws to justify the 4σ² component result; compute
uniform signed-amplitude moments using normalized restricted Lebesgue measure.
Document zero-direction, direction-law and norm-variance corrections.

## Build Structure

Both new modules are leaves above Algebra, independent of calculus/BPTT.
Generic variance imports stay in InitializationMoments; Gaussian/Uniform each
import only their required law/integration infrastructure. Deterministic definitions
remain separately importable. Focused builds: Qrnn.InitializationCore and
Qrnn.InitializationMoments. Add API/audit re-exports after focused checks pass.

## Boundary Checks

No sorry, new project axioms, fabricated density calculation, silently assumed
integrability, positive scale/fan or nonzero direction. Distinguish second moment
and scalar norm variance. Exclude convergence, uniform-sphere, and empirical
claims unless separately proved. All caches and artifacts stay in this folder.

## Completion Requirements

Norm identities for pure unit directions; integrable component moment theorem;
Gaussian centered-vector second moment; bounded-amplitude uniform second moment;
correct normalization/scale assumptions; explicit variance correction; source
map, axiom audit, focused builds, proof-hole scan and diff checks.
A chi-density derivation is optional if the required moment result is proved
from actual component laws; record this scope plainly.

## Stage Results

Completed 2026-09-26:
- polar_norm_sq/polar_norm prove squared amplitude and absolute amplitude for
  pure unit directions. sampledDirection requires a nonzero imaginary sample;
  zero_direction_polar_counterexample verifies failure at the zero fallback.
- quaternionSecondMoment_components and quaternionVariance_eq separate norm
  second moment, covariance trace and scalar norm variance, with integrability/
  L2 hypotheses explicit. quaternionNorm_mean_pos and the strict variance theorem
  refute the paper's zero-mean-norm inference for every nontrivial integrable model.
- gaussianQuaternion_secondMoment/variance derive 4v from actual N(0,v) marginal
  laws using mathlib Gaussian integrals and finite moments. Independence is not
  needed here. The chi4 density/law and closed-form Gaussian mean norm are not
  proved or required for these moment results; the paper's density derivation
  remains outside this verified surface rather than an imported assumption.
- uniformPolar_secondMoment/norm_mean/norm_variance give σ²/3, σ/2 and σ²/12
  from the actual continuous uniform signed amplitude law. They need no angle/
  direction independence. uniformPolar_quaternionVariance gives covariance trace
  σ²/3 with measurable factors and amplitude-factor independence explicit.
- imaginarySample_nonzero_ae proves one continuously uniform positive coordinate
  excludes zero normalization almost surely; no coordinate independence is needed.
  sampledDirection_imI_nonnegative records the positive-octant support constraint;
  normalization is not a justification for full-sphere isotropy.
- gaussianScale_secondMoment proves the intended 2/fan target for Gaussian
  component scaling; the paper's bounded amplitude instead yields 1/(6 fan).
  uniformAmplitudeBound and correctedUniformPolar_secondMoment repair the bound
  to sqrt(3 target), including target 2/fan, without a convergence guarantee.
- Focused builds of all four mathematical leaves and InitializationAudit passed.
  Public API build passed (3114 tasks); explicit audit passed (76 results, only
  propext/Classical.choice/Quot.sound). Scans/diff checks passed.
- Only required pinned cache closures were fetched (680 additional artifacts);
  all dependency/build/cache files remain in this folder.

Next: stage 5 QLSTM real-coordinate recurrence, architecture parameter counts,
and explicit scalar-operation cost model.
