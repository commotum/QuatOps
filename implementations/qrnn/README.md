# Quaternion recurrent neural networks: Lean scaffold

Scope: this directory only, including dependencies, build artifacts, and goals.
The source is [Quaternion_Recurrent_Neural_Networks.md](Quaternion_Recurrent_Neural_Networks.md), preserved unchanged.
Formalization is in progress. The completed scaffold is retained in `goal-1`;
its validation record describes the initial state, not completion of the library.

Start with [goal-1/0-plan.md](goal-1/0-plan.md). Supporting documents:
- [Paper map](goal-1/paper-map.md): source locations and proposed declarations.
- [Audit and corrections](goal-1/audit.md): preliminary issues and explicit proof status.
- [Dependencies and design](goal-1/dependencies.md): pins, conventions, and open choices.
- [Theorem outline](goal-1/theorem-outline.md): intended statements and hypotheses.
- [Validation](goal-1/validation.md): actual scaffold checks and build evidence.

From this directory, use `MATHLIB_NO_CACHE_ON_UPDATE=1 lake update` to resolve the pinned dependency, then
`MATHLIB_CACHE_DIR="$PWD/.cache/mathlib" lake exe cache get Mathlib.Algebra.Quaternion`
and `lake build`. Keep generated caches in this directory. Commit the lockfile;
never silently change the toolchain or dependency pins to make a proof build.

Substantive continuation was authorized on 2026-09-25. See the plan for current
verified results and remaining work.
