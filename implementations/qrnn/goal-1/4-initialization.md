# 4-initialization

## Current Facts

Stages 1–3 compile; full gradients and the literal-error-product counterexample
are verified. The paper initialization uses a signed uniform amplitude in
[-σ,σ], a uniform angle, and a normalized positive-octant imaginary direction.
Its appendix instead assumes four independent centered Gaussian components.
Mathlib supplies quaternion normSq, real integration, Gaussian laws and moments,
and ordinary scalar variance. No initialization proofs exist yet.

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
Create InitializationMoments for component integrals and variance identities.
Use mathlib real Gaussian laws to justify the 4σ² component result; compute
uniform signed-amplitude moments using normalized restricted Lebesgue measure.
Document zero-direction, direction-law and norm-variance corrections.

## Build Structure

Both new modules are leaves above Algebra, independent of calculus/BPTT.
Probability imports stay in InitializationMoments; deterministic definitions
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

In progress. Next inspect the pinned probability APIs and prove deterministic
polar norm algebra before probability integration.
