# 5-architecture

## Current Facts

Stages 1–4 are verified. Forward defines QRNN and QLSTM gate/cell equations with
Hamilton affine maps and componentwise gate products. QRNN real expansion is
proved; QLSTM real expansion/unrolling and exact parameter/cost statements are
not yet implemented. Source experiment diagrams/tables are missing locally.

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

In progress: implement QLSTM real coordinate equivalence first.
