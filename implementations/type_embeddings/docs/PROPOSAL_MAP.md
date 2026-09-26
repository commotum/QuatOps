# Proposal-to-library map

Source: `../type_value_embeddings_proposal.md`, sections below. This is a planned map;
all proposed declarations are unimplemented. See `THEOREM_OUTLINE.md` for statements.

| Source | Claim category | Planned coverage |
|---|---|---|
| §2 enumeration and memory | Exact count / storage convention | `rgbGrid_card`, baseline cardinalities; 512×256³=8,589,934,592 coefficients and 2 bytes each gives 16 GiB (GiB=2³⁰ bytes), excluding all other storage |
| §3 typed interface | Architecture / conditional probability | Record interface only; optional `typedJoint_sum`; no theorem about transformer states, greedy type choice, parser quality, or text preservation |
| §4 MR | Exact grid | `channelValue_*`, `rgbGrid_card`, pure RGB insertion |
| §4 BF16 | Representation, separate from arithmetic | Dyadic representation first; BF16 theorem only with a specified format model |
| §5 quaternion bank | Exact real algebra | `rightMul_*`, `stacked_gram`, `encoder_gram`, rank/injectivity, singular values and conditioning |
| §6 fused readout | Exact least squares | `decoder_fused`, Moore–Penrose identities, round-trip and noise bound |
| §6 grid decoder | Exact finite optimization | Fixed ties/clipping, margin recovery, score decomposition, global RGB optimum |
| §6 top-k suggestion | Algorithm proposal | Deferred; fixed neighborhood has no general guarantee; no top-k theorem planned in initial core |
| §7 finite-grid probabilities | Chosen modeling family + exact normalization | Positive scales, channel normalizers, product PMF, modes; independence is a modeling assumption |
| §7 Gaussian claims | Conditional statistical model | Later only with isotropic Gaussian assumptions; d−3>0 and expectations/covariance defined |
| §7 agreement | Counterexample / limitation | `wrongCode_zeroResidual`; no residual-to-calibration implication |
| §8 training/normalization | Architecture / numerics | Document nonzero raw bank for energy normalization, actual-weight denominator, and output-state assumptions; no training/FP32 exactness theorem |
| §9 coefficient counts | Definitional combinatorics | `coreCoefficient_count`, `baseline_counts`; include scale predictor 3d+3 separately |
| §9 O(d) | Explicit arithmetic/iteration model | Proposed encoder/decoder cost theorems; no latency or speedup theorem |
| §10 int64 and multiple inputs | Serialization / later extension | 2⁶⁴ count may be definitional; byte order, signed conversion, and full-rank larger encoder need independent specifications |
| §11 reported checks | Numerical/symbolic experiments | Source reports only; script/results unavailable locally; no theorem follows from these reports |
| §11–12 model benefits | Empirical outcomes / proposal | Outside verified mathematical core |

The BF16 example RGB (237,169,1)→(237,169,0) is a reported storage-rounding
counterexample, not reproduced evidence here. A formal reconstruction of that exact
example needs its weights and execution semantics. The general distinction between
representable input grids and inexact projected arithmetic must remain explicit.
