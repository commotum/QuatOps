# Quaternion recurrent neural networks: Lean scaffold

Scope: this directory only, including dependencies, build artifacts, and goals.
The source is [Quaternion_Recurrent_Neural_Networks.md](Quaternion_Recurrent_Neural_Networks.md), preserved unchanged.
This is a scaffold, not a formalization. The Lean files contain only imports and comments.

Start with [goal-1/0-plan.md](goal-1/0-plan.md). Supporting documents:
- [Paper map](goal-1/paper-map.md): source locations and proposed declarations.
- [Audit and corrections](goal-1/audit.md): preliminary issues and explicit proof status.
- [Dependencies and design](goal-1/dependencies.md): pins, conventions, and open choices.
- [Theorem outline](goal-1/theorem-outline.md): intended statements and hypotheses.
- [Validation](goal-1/validation.md): actual scaffold checks and build evidence.

From this directory, use `lake update` to resolve the pinned dependency, then
`MATHLIB_CACHE_DIR="$PWD/.cache/mathlib" lake exe cache get Mathlib/Algebra/Quaternion/Basic.lean`
and `lake build`. Keep generated caches in this directory. Commit the lockfile;
never silently change the toolchain or dependency pins to make a proof build.

Stop after scaffolding. Implementation requires explicit user instructions.
The continuation prompt is for use after that authorization, not permission by itself.
