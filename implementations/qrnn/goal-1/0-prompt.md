# Goal prompt

```text
Build a correct, reusable Lean 4 library for Quaternion Recurrent Neural Networks, covering quaternion algebra and real representations, QRNN recurrence, QBPTT and all parameter gradients, initialization moments, QLSTM forward equations, and exact architecture counts. Work exclusively in implementations/qrnn, including goal records and build artifacts.

Read implementations/qrnn/goal-1/0-plan.md for the full objective, constraints, stages, and current status, and implementations/qrnn/goal-1/0-loop.md for the working rhythm. Sync the plan with the actual files, results, and completed work. Select the first unfinished stage and continue through the stages toward the full objective, using current evidence and best judgment for implementation.

Independently audit the source, record corrections, and use pinned Lean/mathlib. Completed modules must have no proof holes or unexplained project axioms. Make shape, multiplication-order, differentiability, and probability assumptions explicit. Keep verified mathematics distinct from optimization assertions and empirical results.

Confirm important outcomes with suitable builds and mathematical checks. Fold material results, decisions, corrections, and stage status back into the plan. If a session ends mid-goal, leave a brief note with the next action so the goal remains resumable.

Completion means the original objective and active stages are achieved with reusable definitions and theorems, a reproducible build, a faithful source-to-declaration map, correction records, and an actual main-result axiom audit. Match completion claims to observed results and report real blockers or uncertainty plainly.
```
