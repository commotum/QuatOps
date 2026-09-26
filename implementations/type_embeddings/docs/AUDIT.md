# Corrections, assumptions, unresolved points, and axiom audit

Quaternion and bank stages now have compiled substantive proofs and actual axiom audits.
No numerical reproduction has been performed. The qualifications below remain scope
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
4. Nearest-grid minimizers need not be unique. Adopt smallest-index ties provisionally;
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

## Unresolved design choices

Linear maps first versus matrices first; bank product/flattening indices; exact rounding
implementation versus finite argmin specification; PMF packaging over finite RGB;
formal BF16 semantics and the extent of Gaussian work; operation-count semantics.
Resolve these from actual mathlib APIs and proof usability after continuation.
No material correction to the source is claimed proved at this stage.

## Axiom status and future audit procedure

The public root exports completed quaternion and bank leaves; diagnostics remain
separate. Actual `#print axioms` runs for 8 quaternion results and 20 bank results
report exactly `[propext, Classical.choice, Quot.sound]`. No `sorryAx` or custom
project axiom is reported. Audit sources are
`TypeEmbeddings/Diagnostics/QuaternionAxioms.lean` and `BankAxioms.lean`.
Build these targets explicitly to reproduce the checks.

For every subsequent main result, run Lean `#print axioms` for each mapped major declaration
in a reproducible audit target and record actual output with the build/toolchain.
Reject `sorryAx` and unexplained project-specific axioms. Distinguish normal Lean
foundations (such as classical choice, propositional extensionality, quotient soundness)
from stated theorem hypotheses and any external numerical semantics. Text searches
supplement compilation and actual audits; they do not substitute for them.
