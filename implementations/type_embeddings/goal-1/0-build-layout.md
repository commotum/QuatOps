# 0-build-layout

> Historical import-only build-layout record. Current public-root imports and proof
> coverage are recorded in `0-plan.md` and `../docs/VALIDATION.md`.

## Current Facts

The project is a validated scaffold with no mathematical declarations. Its sole public
root imports eight candidate mathlib modules, including probability and singular values
that early quaternion consumers will not need. The default build previously visits
2868 jobs. The user requested build-time optimization under `../BUILD-PLAN.md`.

## Updated Assumptions

The build-layout maintenance is authorized. Pins and Lean correctness checks stay intact.
No substantive mathematical implementation is needed for this change. The continuation
prompt's self-defeating stop clause will be removed so an explicit continuation request
can initiate work without a second authorization loop.

## Big Picture Objective

Make scaffold dependency checks optional and keep the public root thin, establishing
narrow imports and focused verification for subsequent mathematical work.

## Detailed Implementation Plan

Move the existing imports unchanged into `TypeEmbeddings/Diagnostics/Dependencies.lean`.
Keep `TypeEmbeddings.lean` as a declaration-free public root until real modules exist.
Update build guidance and continuation records. Do not create unused feature skeletons.

## Build Structure

The root is public API scaffolding; the dependency check is diagnostic scaffolding.
Internal mathematical leaves must import their specific prerequisites, never the root
or diagnostic target. Heavy probability, spectral, and numerical proof leaves should
be imported only by consumers that need them. Default Lake globs build only library
roots, so the diagnostic stays available through an explicit module target.

Focused build: `lake build TypeEmbeddings.Diagnostics.Dependencies`.
Adjacent public/configuration check: `lake build`.

## Boundary Checks

No declarations, theorem statements, axioms, proof holes, global attributes, or instances
are introduced. The diagnostic retains all eight original mathlib imports. Dependency
pins remain unchanged. Default root must not import the diagnostic.

## Completion Requirements

Both targets compile. Source inspection confirms the import boundary and no proof holes.
Record actual build output, cached timing observations, and whitespace checks. Update
README, dependency/validation notes, plan, loop, and prompt without claiming mathematical
completion or a general proof-elaboration speedup.

## Stage Results

Complete. Original imports moved intact into the diagnostic leaf; public root is thin.
No mathematical definitions or proofs were introduced or changed. Pins/configuration
are unchanged. Build guidance and continuation records were updated; the prompt no
longer denies its own authority when invoked for continuation.

- Baseline cached `lake build`: success, 2868 jobs, 2.179s.
- `lake build TypeEmbeddings.Diagnostics.Dependencies`: success, 2867 jobs, 4.141s
  including first elaboration of the new diagnostic leaf (reported 2.0s).
- First updated `lake build`: success, 3 jobs, 0.970s (root elaboration 277ms).
- Repeated updated cached `lake build`: success, 3 jobs, 0.829s.
- Import boundary/source checks pass; all eight diagnostic imports preserved.
- Proof-hole scan hits only documentary axiom-audit requirements, not Lean code.
- `git diff --check -- implementations/type_embeddings` from repository root passes;
  direct whitespace scan also passes (files are currently untracked).

These are local cached timings, not clean-build or future proof-performance guarantees.
The concrete improvement is removing 2865 optional jobs from the default graph.
No stage-1 mathematical obligation has been discharged. Next mathematical work starts
with a narrow right-multiplication module and its own focused build.
