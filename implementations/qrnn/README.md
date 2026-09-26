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

For incremental development, import specific modules rather than `Qrnn`:
`Qrnn.ActivationCore` supplies split activation definitions, `Qrnn.Forward`
supplies forward architectures, `Qrnn.Activation` supplies activation calculus,
and `Qrnn.BPTT` supplies generic real BPTT without quaternion dependencies.

Build the touched leaf first, for example `lake build Qrnn.QRNNBPTT`. Build
adjacent consumers after dependency changes; use `lake build` for public API or
configuration changes and integration checks. Diagnostics are separate:
`lake env lean Qrnn/AxiomAudit.lean > goal-1/axioms.txt`. The public library does
not import audit printing. See [stage 3 build notes](goal-1/3-bptt.md) for measured
results and the next mathematical targets.
