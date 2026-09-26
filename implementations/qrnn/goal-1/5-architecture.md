# 5-architecture

## Current Facts

Stages 1–4 are verified. Forward defines QRNN and QLSTM gate/cell equations with
Hamilton affine maps and componentwise gate products. QRNN real expansion is
proved; QLSTM real expansion/unrolling and exact parameter/cost statements are
now implemented in QLSTMReal, ParameterCounts and OperationCounts. Source experiment diagrams/tables are missing locally.

## Updated Assumptions

Count independent real scalar coordinates, not all entries in a tied real block
matrix. Quaternion widths d,h,o correspond to real widths 4d,4h,4o. QRNN has no
output bias. QLSTM has four gate/candidate affine maps and no output head unless
one is separately supplied. Use a stated naive Hamilton cost model; arithmetic
counts are not wall-clock speed guarantees.

## Big Picture Objective

Verify QLSTM real-coordinate forward recurrence, exact one-layer parameter
counts with bias corrections, and conditional scalar-operation counts. Separate
those mathematical/architecture results from experimental size/runtime claims.

## Detailed Implementation Plan

Add QLSTMReal as a leaf above Forward. Add ParameterCounts as a leaf above Forward
with finite index types matching actual parameter families and coordinate counts.
Add OperationCounts for a declared dense scalar schedule and polynomial costs.
Keep probability and calculus dependencies out of these leaves. Focused builds
then API/audit integration once declarations compile.

## Build Structure

QLSTMReal: forward definitions/proofs; ParameterCounts: architecture coordinate
indices/counts; OperationCounts: proof-side schedule/cost model. Forward and
Algebra remain stable. Focused commands: lake build Qrnn.QLSTMReal,
Qrnn.ParameterCounts, Qrnn.OperationCounts. Full build only on API import changes.

## Boundary Checks

No global fourfold whole-model claim including biases; no empirical total or
runtime guarantee; no unstated asymptotic dimension scaling. Declare omitted
candidate Hamilton symbols as an interpretation, with no QLSTM gradient claim.
No proof holes/project axioms; diagnostic leaves excluded from public imports.

## Completion Requirements

QLSTM step/run real equivalence; finite parameter index cardinalities tied to
specified architecture; weight-only fourfold saving and exact bias discrepancy;
scalar operation counts under a documented schedule with activation costs
explicit; build/scan/axiom checks and faithful paper map/correction fold-back.

## Stage Results

Completed 2026-09-26:
- qlstmStep_expand/qlstmRun_expand verify the full real-coordinate forward step
  and finite-horizon recurrence, with explicit fixed initial cell/hidden state.
- matrixCoordinateEquiv, qrnnCoordinateEquiv and qlstmCoordinateEquiv are checked
  bijections to unrestricted real coordinate functions. Count identities therefore
  count actual independent parameters, not redundant real expansion entries.
- weight_parameter_count gives 4mn; arbitrary block-sized real weights have
  16mn. QRNN has 4(h²+hd+oh+h); QLSTM has 16(hd+h²+h), without an output head.
- Whole-model bias corrections at matched real widths are 12h (QRNN) and 48h
  (QLSTM): real_count + correction = 4*quaternion_count. The weight-only factor
  is exactly four; a whole-model unqualified fourfold assertion is rejected.
- OperationCounts supplies finite scalar-operation index types and proves
  Hamilton 16 multiplications/12 additions. The stated zero-accumulation schedule
  gives QRNN cost 32(h²+hd+oh)+8h+4hα+4oβ and QLSTM cost
  128(hd+h²)+48h+12hα+8hτ, including fixed scalar activation costs.
- Equal-width polynomial formulas and explicit quadratic upper/lower bounds
  state the scaling assumptions. Sequence schedule costs multiply by T. These
  do not claim optimized arithmetic, actual Lean evaluator cost, BPTT runtime,
  measured training speed, or a CUDA performance result.
- Focused builds passed, including the parameter-count consumer OperationCounts.
  Public build and explicit 102-result axiom audit are required at integration.
  Source experiment totals remain outside scope: referenced tables/diagrams
  are absent, and the counts specify a single layer/direction explicitly.

Next: final integration, clean project build and requirement-by-requirement audit.
