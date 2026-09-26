# Corrections, assumptions, unresolved points, and axiom audit

Quaternion, bank, and exact RGB decoding stages now have compiled proofs and actual axiom audits.
The source numerical scripts have not been reproduced; a different exact-rational
BF16 rounding witness has been proved independently in Lean. The qualifications below remain scope
requirements; the declaration map identifies which obligations are discharged.

## Required qualifications

1. Gram identities hold even at S=0; injectivity, unique least squares, inverse gain,
   three positive singular values, and inverse formulas need S>0. An empty bank cannot
   satisfy S>0. Individual zero weights are allowed in the fused expression.
2. Right multiplication in scalar/i/j/k order fixes matrix signs and the order of the
   conjugate in the reader. A left-multiplication matrix would be a different encoder.
3. ℓ² bounds require Euclidean norms. Plain coordinate functions may carry a maximum
   norm; bridge these representations explicitly. A maximum coordinate error strictly
   below 1/256 gives recovery, while equality can tie and need not recover the target.
4. Nearest-grid minimizers need not be unique. Existing code uses smallest-index ties; revised §7 requires ties-to-even compatibility, still pending;
   clipping handles locations outside the grid. Least-squares uniqueness refers to the
   continuous solution under S>0, not necessarily the discrete argmin.
5. Mathlib's singular-value sequence has zero entries after the domain dimension.
   Say its first three values equal √S, not that every entry of the sequence does.
6. A left inverse alone does not establish Moore–Penrose pseudoinverse status. Prove
   the four identities/orthogonal projector properties, and state the chosen condition
   number definition for a rectangular full-column-rank operator.
7. The probability formula is normalized by construction only after proving finite
   normalizers positive. s>0 is the proposal's modeling convention; this kernel scale
   is neither generally the actual standard deviation nor a calibration guarantee.
   A joint mode need not be unique and μ need not be its mean.
8. Under Gaussian observation noise, residual variance needs d−3>0 and a defined
   distribution/expectation. Here S>0 implies N≥1, hence d=4N≥4. Do not silently
   generalize an unbiased noise estimator into predictive confidence.
9. Counts refer to stored trainable coefficients, not necessarily independent degrees
   of freedom after fixed-energy normalization. Probability scales, offsets, type
   embeddings, adapters and text parameters are additional. O(d) needs an explicit
   cost model and says nothing about hardware latency.
10. Exact BF16 grid representation is separate from exact multiplication, summation,
    storage of the expanded code, or transformer prediction. FP32 accumulation is
    not an exactness guarantee. Define numerical semantics before formalizing them.
11. Multiple quaternion inputs summed into the same output have mixed Gram blocks.
    Establish their vanishing or use disjoint banks/full-rank analysis; single-input
    S I cannot be reused unchanged. Int64 payload serialization is separate work.
12. Source verification script/results are unavailable in this folder. Its reported
    symbolic checks, errors, Monte Carlo statistics, and BF16 counterexample have
    not been independently reproduced. Preserve the zero-residual/wrong-target and
    representable-grid/inexact-round-trip distinctions.

## Revised-source corrections and remaining assumptions

Active source is `type_value_embeddings_revised_proposal.md` (REVISION.md records hash).
The original additive TYPE embedding and separate classifier are superseded. Shared
TYPE/VALUE banks reuse existing per-bank results; concatenation does not imply transformer
slice preservation. No unified interface or head is yet claimed implemented.

- Revised positive width requires floor>0,γ>0,S>0 and d−3>0. Bank positivity implies
  N≥1, hence d=4N≥4; prove this dependency explicitly before dividing. Width increases
  with residual energy only holding other inputs/settings fixed. A zero residual reaches
  the floor even for a wrong code, so this parameterization does not imply calibration.
- Equal-norm TYPE score equivalence applies to exact codes. FP32 storage generally
  perturbs norms; distinctness/equal norms of the actual used codes must be established
  or the exact squared-distance likelihood retained. Positive separation needs a finite
  distinct codebook with at least two types; one-type classification is a separate case.
- The reconstructed Gibbs likelihood has scalar T(h)=2S s²(h), positive and constant
  across candidates. Independent channel scales only specialize to it when equal; a
  candidate-dependent width would invalidate the cancellation argument.
- Revised default counts include K+1 learned gains; no learned TYPE code coordinates,
  dense contraction, or scale-predictor matrix is assumed. The 64/448 one-RGB example
  totals 514, not 512. Optional text and bypassed one-type banks need separate accounting.
- Clipped ties-to-even mode selection is required by revised §7. Existing half-down
  code proves optimality but differs at ties. Strict-margin results survive; use separate
  convention-specific declarations. Clamping before machine conversion is an engineering
  guard; it must not alter likelihood locations.
- The revised top-k heap claim needs sorted arrays, a visited-set invariant and a stated
  cost model before a theorem. Approximate O(k log k) language is not exact evidence.
- Revised script/results and cited upstream README are absent; numerical gradients,
  unified trials and exhaustive top-100 are reported only, not formal verification.

The numerical diagnostic proves an independent (0,0,16)→(0,0,17) ideal-normal BF16
storage witness with exactly representable weight (1,2,3,4) and an exact real decoder.
It does not reproduce the source's (237,169,1)→(237,169,0) FP32 trace. Grid representation
is proved using a kernel-checked rational certificate, without asserting operation exactness.
`wrongCode_zeroResidual` and `sharedTwoInput_not_injective` preserve the other limitations.

Resolved design choices: Euclidean locations, PiLp quaternion banks, product-indexed
stacked matrices, explicit adjoint/four Penrose identities, real finite sums then PMF.
Unfinished: ties-to-even mode interface, residual-width/TYPE/joint likelihood, revised
structured counts/cost, and a consolidated final axiom audit. Gaussian law, heap top-k,
serialization and broader heads remain separately specified extensions.

## Axiom status and future audit procedure

The public root exports completed quaternion, bank, RGB, probability and count leaves; diagnostics remain
separate. Actual `#print axioms` runs for 8 quaternion results and 20 bank results
report exactly `[propext, Classical.choice, Quot.sound]`. Twelve grid/decoding results
were additionally checked with the same output in `Diagnostics/GridAxioms.lean`. No `sorryAx` or custom
project axiom is reported. Audit sources are
`TypeEmbeddings/Diagnostics/QuaternionAxioms.lean` and `BankAxioms.lean`.
ProbabilityCountAxioms additionally checked thirteen probability/count main results
with the same standard-axiom set. Numerical/limitation consolidated checks are pending.
Build these targets explicitly to reproduce the checks.

For every subsequent main result, run Lean `#print axioms` for each mapped major declaration
in a reproducible audit target and record actual output with the build/toolchain.
Reject `sorryAx` and unexplained project-specific axioms. Distinguish normal Lean
foundations (such as classical choice, propositional extensionality, quotient soundness)
from stated theorem hypotheses and any external numerical semantics. Text searches
supplement compilation and actual audits; they do not substitute for them.
