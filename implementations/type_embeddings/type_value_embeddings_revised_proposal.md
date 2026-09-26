# Feature Proposal: Type & Value Embeddings
## Unified quaternion encoding and probabilistic decoding

**Status:** Revised proposal for an RGB-first research prototype. The algebra and reference calculations have been checked; trained-model accuracy, calibration, and hardware performance have not been established.

## 1. Executive summary

Represent a structured token as **(TYPE, VALUE)**. Map each component into a compact **minimal representation (MR)**, then lift it into its assigned embedding segment using a learned quaternion **weight bank**. At the output, reuse those banks in a tied **quaternion voting decoder**.

The same mechanism handles TYPE and supported structured VALUEs. There is no independent learned contraction matrix, no RGB row-per-value table, and no 16,777,216-way RGB projection. A small TYPE codebook remains; an optional conventional text branch retains its ordinary vocabulary table. This preserves the README's unified architecture while incorporating the earlier proposal's mathematical and implementation safeguards. [1, 2]

The revised decoder produces a continuous location and a residual-derived distribution width. Explicit normalized distributions turn those outputs into type probabilities and RGB probabilities. Exact RGB mode selection requires only channelwise rounding; full-domain sampling requires three 256-bin normalizations.

**The principal experimental question is whether this compact, tied interface delivers useful predictive quality at lower total cost than compact real-valued or categorical alternatives.** Algebra establishes the reader's properties; training must establish its usefulness.

## 2. Motivation and initial scope

A hypothetical RGB row-per-value table has

\[
|\mathcal V_{\mathrm{RGB}}|=256^3=16{,}777{,}216
\]

rows. With 512 real coefficients per row, one table contains 8,589,934,592 coefficients and occupies **16 GiB in BF16**, before optimizer states. The structured alternative scales with embedding width and the number of supported types, rather than the number of possible RGB values.

This comparison concerns atomic value enumeration. Serializing values as ordinary text or bytes is also possible and must be included as a baseline; the feature does not assume an existing tokenizer needs a row for every color.

The first implementation will support RGB payloads, shared TYPE decoding, and an optional conventional TEXT branch. The input/output interface changes, but attention and MLP blocks need not change. Existing checkpoints will still require an explicit embedding/head adaptation plan; this is not automatically a drop-in checkpoint conversion.

Arbitrary int64 support and richer multimodal value distributions are extensions, not prerequisites for the RGB prototype.

## 3. Typed-token contract and architecture

Let

\[
z=(\tau,v),\qquad
D=d_T+d_V,
\]

where both segment widths are positive multiples of four.

For a structured value, construct

\[
\boxed{
e(z)=E_T(a_\tau)\;\Vert\;E_\tau(\phi_\tau(v)).
}
\]

Here \(a_\tau\in\mathbb R^3\) is a fixed TYPE code, \(\phi_\tau\) is the type-specific MR mapping, and \(\Vert\) denotes concatenation. Both encoders use the quaternion construction below. Position handling remains part of the host architecture.

The transformer processes the complete vector. TYPE and VALUE slices are **input/output conventions**, not isolated information channels: attention and MLP transformations may mix them freely. Training makes the designated output slices useful to their readers. This retains the source's shared-bank architecture without assuming that arbitrary transformations preserve slice separation. [1, lines 116–128]

Read the final residual stream before any optional terminal normalization:

\[
h=h_T\;\Vert\;h_V.
\]

Decode \(h_T\) with the shared TYPE bank, then decode \(h_V\) with the selected VALUE bank. This avoids imposing a terminal fixed-norm constraint on the reader inputs; post-normalization variants are ablations.

Factor the next-token distribution as

\[
\boxed{
p(\tau,v\mid H)=p(\tau\mid h_T)\,p_\tau(v\mid h_V),
}
\]

where \(H\) is the preceding context. Both hidden slices may depend on all of \(H\).

### Parsing and text compatibility

Accept explicit typed fields or a documented reversible parsing rule. Do not reinterpret ambiguous ordinary text silently. Numeric equality does not preserve spelling or formatting; retain that information separately when required.

In the optional TEXT branch, use the same TYPE encoder/decoder, but retain conventional text-token embeddings and a normalized vocabulary head for the VALUE component. A from-scratch concatenated implementation can give text rows width \(d_V\). Adapting a pre-existing full-width text embedding requires separate engineering and parameter accounting. The hybrid model is table-free for RGB, not for ordinary text.

## 4. Minimal representations

### RGB

For each byte \(c\in\{0,\ldots,255\}\), define

\[
\phi(c)=\frac{2c-255}{256}.
\]

The RGB MR is

\[
x=(\phi(r),\phi(g),\phi(b))^\top,
\qquad
q=Px=(0,x_1,x_2,x_3)^\top,
\]

where \(P\) inserts the zero real component.

The grid has endpoints \(\pm255/256\) and spacing \(\Delta=1/128\). Every point is exactly representable in BF16: its integer numerator has at most eight significant binary digits and its denominator is a power of two. BF16 provides seven stored fraction bits plus the implicit leading bit for normal numbers. [3]

Construct the mapping in signed-integer or FP32 arithmetic before casting. This avoids overflow in unsigned-byte arithmetic. Exact MR representation does not guarantee exact later projections or predictions.

“Minimal” means compact and structure-preserving, not bit-optimal: RGB has three informative coordinates; the quaternion's real coordinate is fixed.

### TYPE

Assign each supported type a distinct, fixed, well-separated code

\[
a_\tau\in\mathbb R^3,\qquad\|a_\tau\|=1,
\]

and encode \(Pa_\tau\) as a purely imaginary quaternion. Store and version this small codebook in FP32. Check distinctness and minimum separation when registering types. Its coordinates are fixed buffers, not learned per-value embeddings.

A unit code can represent each type, but the resulting classifier has a three-coordinate scoring bottleneck. This is a deliberate compactness tradeoff, evaluated against a conventional classifier rather than assumed equivalent in expressive power.

## 5. Shared quaternion encoder and exact linear reader

For a segment of width \(d_s=4N_s\), learn quaternion weights

\[
W_1,\ldots,W_{N_s}\in\mathbb H.
\]

Use right multiplication consistently:

\[
E_W(x)=\operatorname{vec}\left(
(Px)\otimes W_1,\ldots,(Px)\otimes W_{N_s}
\right)=B_Wx.
\]

There are \(4N_s=d_s\) learned real bank coefficients. Quaternion parameter sharing has prior neural-network applications; that literature does not by itself validate this particular typed-token interface. [4]

Define total bank energy

\[
S_W=\sum_i\|W_i\|^2.
\]

Quaternion norm multiplicativity gives

\[
\boxed{B_W^\top B_W=S_WI_3}.
\]

Consequently, whenever \(S_W>0\),

\[
\boxed{B_W^+=\frac{B_W^\top}{S_W}},
\qquad B_W^+B_W=I_3.
\]

All three singular values equal \(\sqrt{S_W}\). The encoder is a **scaled isometry**: it preserves Euclidean MR distances up to a common scale, and its spectral condition number is one. Its absolute inverse gain is \(1/\sqrt{S_W}\), so bank energy must not collapse.

For an arbitrary output segment \(h_s\), reshape it into quaternion blocks \(h_i\) and compute

\[
\boxed{
\mu_W=
\frac{\operatorname{Im}\left(\sum_i h_i\otimes\overline{W_i}\right)}{S_W}
=B_W^+h_s.
}
\]

This is the unique least-squares solution to \(\min_x\|h_s-B_Wx\|^2\). It is the fused form of the source's norm-weighted inverse votes. [1, lines 73–91]

**Implement this fused expression directly.** It avoids divisions by individual block norms and supports zero individual weights as long as total bank energy is positive. The complete reader costs \(O(d_s)\), not constant time.

For \(h_s=B_Wx\), recovery is exact in exact arithmetic. For \(h_s=B_Wx+\varepsilon\),

\[
\|\mu_W-x\|_2\le\frac{\|\varepsilon\|_2}{\sqrt{S_W}}.
\]

This is an encoder–reader theorem, not an inversion of the transformer. End-to-end training must produce a useful final state.

## 6. Residual-derived width without an additional readout matrix

Compute the constrained reconstruction residual

\[
R_W(h_s)=\|h_s-B_W\mu_W\|^2.
\]

Use the same proposed width rule for TYPE and RGB:

\[
\boxed{
s_W^2(h_s)=s_{\min,W}^2+
\gamma_W\frac{R_W(h_s)}{S_W(d_s-3)},
\qquad\gamma_W=\operatorname{softplus}(\rho_W)>0.
}
\]

Here \(s_{\min,W}>0\) is a fixed scale floor and \(\rho_W\) is one learned scalar per bank, initialized so that \(\gamma_W=1\). There is no independent learned matrix for predicting uncertainty.

This residual-dependent parameterization is a **revised experimental design choice**. It makes the source's intended relationship between disagreement and distribution width operational: larger residuals increase the width used by the actual probability model, rather than producing a disconnected diagnostic.

Under the explicit observation model

\[
h_s=B_Wx+\varepsilon,
\qquad\varepsilon\sim\mathcal N(0,\sigma^2I_{d_s}),
\]

\[
\operatorname{Cov}(\mu_W\mid x)=\frac{\sigma^2}{S_W}I_3,
\qquad
\mathbb E\left[\frac{R_W}{d_s-3}\right]=\sigma^2.
\]

That motivates the normalization; it does not establish Gaussian transformer errors. With a learned gain, positive floor, and finite output support, the proposed distribution is not claimed to be an exact Bayesian posterior under this observation model.

In particular, \(h_s=B_Wx_{\mathrm{wrong}}\) has zero residual even when its prediction is wrong. Agreement alone is not correctness. Evaluate calibration against held-out outcomes, and compare this rule with a learned fixed scale and a small explicit scale predictor. Calibration of neural-network probabilities is a separate empirical requirement. [5]

For API purposes, expose **location**, **kernel scale**, **consistency residual**, and **normalized probabilities**. Do not label the residual itself a calibrated confidence score. The kernel scale is also not necessarily the standard deviation of the finite discrete distribution.

## 7. Normalized TYPE and RGB distributions

### TYPE selection

Using the shared TYPE reader's \(\mu_T\) and \(s_T^2\), define

\[
\boxed{
p(\tau\mid h_T)=
\frac{\exp[-\|a_\tau-\mu_T\|^2/(2s_T^2)]}
{\sum_{u\in\mathcal T}\exp[-\|a_u-\mu_T\|^2/(2s_T^2)]}.
}
\]

This needs only a small normalization over the supported types. Because the code norms are equal, the logits are equivalent, up to a common offset, to \(a_\tau^\top\mu_T/s_T^2\). This makes the classifier's low-dimensional restriction explicit.

### RGB likelihood

With \(\mu\in\mathbb R^3\) and scalar \(s^2\) from the RGB reader, define

\[
\boxed{
p(c\mid h_V,\mathrm{RGB})=\prod_{j=1}^{3}p_j(c_j),
}
\]

\[
p_j(a)=
\frac{\exp[-(\phi(a)-\mu_j)^2/(2s^2)]}
{\sum_{b=0}^{255}\exp[-(\phi(b)-\mu_j)^2/(2s^2)]}.
\]

This is normalized over **every RGB value**, with three 256-bin normalizers. It uses small softmaxes; it does not require a giant RGB-vocabulary softmax.

The relationship to reconstruction scoring is exact:

\[
\boxed{
\|h_V-B_W\phi(c)\|^2
=R_W+S_W\|\phi(c)-\mu\|^2.
}
\]

For the context-dependent temperature \(T(h_V)=2S_Ws^2(h_V)\), which is constant across candidates at that context, the likelihood is precisely the normalized distribution proportional to

\[
\exp\left[-\frac{\|h_V-B_W\phi(c)\|^2}{T(h_V)}\right].
\]

Thus the candidate-independent residual cancels from relative scores, but affects their temperature through the explicit width rule. No local candidate cube is required.

### Mode, sampling, and top-k

The exact RGB mode for this single-component likelihood is

\[
\boxed{
\widehat c_j=
\operatorname{clip}_{[0,255]}
\left(\operatorname{round}\left(\frac{256\mu_j+255}{2}\right)\right).
}
\]

Use a documented ties-to-even rule. Exact channel recovery is guaranteed when \(\|\mu-\phi(c)\|_\infty<1/256\). At a rounding tie, either equally probable adjacent bin is a mode.

For sampling, sample the TYPE and then its conditional VALUE; RGB channels are sampled independently from their normalized distributions. For exact RGB top-k, sort each channel's bin costs and use a heap over sums of three costs, maintaining a visited set of rank triples. This explores the needed combinations without a fixed seven-bin cutoff.

For global top-k typed tokens, merge each type's conditional candidates using \(\log p(\tau\mid h_T)+\log p_\tau(v\mid h_V)\). Selecting the most likely type first and taking its modal value is not guaranteed to maximize the joint probability.

## 8. Training objective

For a ground-truth token \((\tau^*,v^*)\), train

\[
\boxed{
\mathcal L=
-\log p(\tau^*\mid h_T)
-\log p_{\tau^*}(v^*\mid h_V).
}
\]

Use the **ground-truth type** to choose the VALUE bank during training. This avoids starving the correct value branch when type prediction is initially wrong. Apply the normal conditional text loss on TEXT examples.

Backpropagate through bank normalization, fused decoding, the residual-derived width, and both normalized likelihoods. Use log-softmax/log-sum-exp; do not compute the training objective by taking logs of rounded probability outputs. Rounding and top-k are inference operations, not the training path.

Do not enable unconditional vote-tightening by default. When residual energy controls width, forcing it toward zero also forces narrow distributions, even for genuinely ambiguous targets. A location-only warm-up or additional regularization may be evaluated, but neither substitutes for the normalized likelihood objective.

## 9. Numerical and implementation requirements

Normalize each raw bank \(V\) to a fixed, nonzero target energy:

\[
W_i=
\sqrt{S_0}\frac{V_i}{\sqrt{\sum_\ell\|V_\ell\|^2}},
\qquad S_0>0.
\]

Choose \(S_0\) to match the intended embedding scale of the host model. This is a fixed bank-level setting, not an additional learned scale per block. Guard against zero or nonfinite raw-bank energy; do not silently replace a degenerate bank with a clamped inverse.

Compute the reader denominator from the actual weights used. For quantized storage, promote the same stored coefficients to FP32 for decoding; do not silently use a different master-weight bank on one side of the tie.

Use FP32 for decoder products and reductions, residual reconstruction, energy calculations, scale computation, probability normalization, and integer conversion. Compute \(R_W\) as an explicit sum of squared reconstruction errors rather than subtracting nearly equal norm-squared quantities. Keep FP32 master parameters when training in mixed precision.

BF16 storage with FP32 accumulation is a documented hardware pattern, but it is not a round-trip guarantee. [6] The reference check reproduces an RGB counterexample in which BF16 rounding of expanded activations changes **(237, 169, 1)** to **(237, 169, 0)** despite FP32 decoder arithmetic. This is not an estimate of trained-model error rates.

Set positive scale floors in MR units. Proposed starting points are \(s_{\min,\mathrm{RGB}}=\Delta/8\) and \(s_{\min,T}=\delta_T/8\), where \(\delta_T\) is the minimum distance between distinct type codes. These are initial hyperparameters, not validated optima; a one-type configuration bypasses TYPE classification. Validate floors and bank energy jointly with numerical range and gradient behavior.

Reject or explicitly handle invalid payloads, nonfinite states, degenerate banks, and out-of-range numerical intermediates. Clamp the continuous RGB location to the grid endpoints before integer conversion at inference to avoid overflow; do not clamp the location before evaluating its likelihood.

## 10. Parameter counts and complexity

For one structured segment of width \(d_s\), the tied quaternion bank uses \(d_s\) learned real coefficients. The residual-width gain adds one scalar. A fixed TYPE codebook adds storage but no learned coefficients.

With \(K\) single-quaternion structured VALUE banks of common width \(d_V\), the shared TYPE bank and these VALUE banks require

\[
\boxed{
P_{\mathrm{structured}}=d_T+Kd_V+(K+1).
}
\]

This excludes the transformer, optional text tables, adapters, and any richer probability heads. It counts stored trainable coefficients, not independent degrees of freedom after bank normalization.

For example, \(D=512\), \(d_T=64\), \(d_V=448\), and one RGB bank require **512 bank coefficients plus two scalar width gains**. The segment split is a prototype setting to tune, not an established optimum.

For the RGB encoder and location reader alone:

| Core design | Learned real coefficients |
|---|---:|
| Tied quaternion encoder and analytic reader | \(d_V\) |
| Dense 3D real encoder with tied analytic pseudoinverse | \(3d_V\) |
| Dense 3D real encoder with independent 3D reader | \(6d_V\) |

These are **3× and 6× core-parameter comparisons**, not whole-model reductions or speedup factors. Compare probability heads and scalar parameters separately on equal terms. A real full-column-rank encoder also has a left inverse, so analytic decoding is not unique to quaternions.

For one TYPE decision followed by an RGB VALUE decision, the structured output cost is

\[
O(d_T+d_V+|\mathcal T|+3\cdot256).
\]

Mode-only RGB decoding after \(\mu\) is available needs constant additional work. Exact top-k adds sorting of the small channel arrays and a best-first search, approximately \(O(3\cdot256\log256+k\log k)\). Global joint search over several types costs more because multiple conditional branches must be evaluated.

Parameter sharing does not guarantee a matching arithmetic reduction. A straightforward pure-RGB quaternion block uses the same 12 real multiplications as a dense \(4\times3\) block. Measure actual kernel and end-to-end performance.

## 11. Representational limits and extensions

The single-component RGB likelihood assumes conditional channel independence and a common scale. It cannot represent separated alternatives such as “red or blue, but not purple.” A small mixture, separate channel scales, or an autoregressive channel distribution is a possible extension; each needs explicit parameter and inference-cost accounting. The exact mode/top-k rules above apply to the specified single-component model, not automatically to every extension.

The RGB input embeddings lie in a three-dimensional subspace and preserve Euclidean channel geometry up to scale. They are not independent embeddings for 16.7 million unrelated symbols. This is the feature's structural assumption, and it should be tested on both tasks that benefit from it and tasks that challenge it.

For signed int64, the exact domain is

\[
-2^{63}\le n\le2^{63}-1,
\qquad |\mathcal V_{\mathrm{int64}}|=2^{64}.
\]

A later implementation can preserve the payload as eight bytes with a documented signed conversion and byte order, and use byte-level likelihoods instead of a \(2^{64}\)-way output table. Exact serialization is distinct from correct prediction. Multiple quaternion inputs require independent code blocks or a separately verified full-rank encoder; summing arbitrary quaternion lifts does not inherit the single-input proof unchanged.

## 12. Verification and evaluation

### Completed reference checks

The accompanying script reruns the earlier checks and adds checks for this unified revision. No transformer was trained.

| Check | Result |
|---|---|
| Quaternion Gram identity, adjoint, and RGB restriction | Verified symbolically |
| BF16 RGB grid and inverse mapping | All 256 channel values pass |
| Shared TYPE and RGB readers | 60 unified trials; maximum exact-code coordinate error \(3.33\times10^{-16}\) |
| TYPE/RGB joint normalization | Maximum error \(1.11\times10^{-15}\) |
| Reconstruction likelihood versus factored likelihood | Maximum log-probability discrepancy \(1.42\times10^{-14}\) on exhaustive \(8^3\) comparison grids |
| Residual-width rule | Verified while varying residual energy independently of location |
| Exact RGB top-100 | Matches one exhaustive 16,777,216-color cost check |
| Gradients through both readers, bank normalization, gains, and joint loss | FP64 numerical gradient check passes |
| Zero-bank behavior | Degenerate bank rejected; individual zero blocks supported |
| Confidence and BF16 exactness overclaims | Explicit counterexamples retained |

Exhaustive RGB enumeration is used **only as a verification oracle**, not as part of the proposed production decoder. These checks establish algebraic and reference-implementation behavior, not calibration, accelerator performance, or model quality.

### Prototype evaluation

Compare the proposed model with text/byte serialization, a tied compact real encoder, an untied real encoder/reader, a fixed orthonormal code, and a small categorical RGB head. Ablate the shared quaternion TYPE classifier against a conventional classifier, and residual-derived width against fixed and explicitly predicted scales.

Measure exact RGB match, channel error, TYPE accuracy, held-out negative log-likelihood, calibration and predictive-set coverage, text-path regression, parameter and memory use, and end-to-end latency. Compare likelihoods at the same underlying data unit when representations use different numbers of tokens.

Include boundary colors, unseen channel combinations, ambiguous or multimodal targets, mixed text/value sequences, and FP32-versus-BF16 tests. Hold the backbone and data constant where feasible, and also compare matched-total-cost configurations.

Before rollout, require serializer round-trips, normalized likelihoods, valid gradients, explicit failure handling, and predeclared task-quality thresholds. Adopt the quaternion variant only when measured quality and cost justify its restrictions.

## 13. Proposed implementation decision

Build an **RGB-first unified TYPE/VALUE prototype** using concatenated interface segments, fixed TYPE codes, normalized quaternion banks, fused tied decoding, residual-derived scale, and globally normalized small-support distributions. Keep conventional text handling available during evaluation.

The feature claim is:

> **Type & Value Embeddings replace row-per-value RGB representations with a compact structured encoder and tied probabilistic decoder. TYPE and RGB VALUE share the same quaternion mechanism. The linear reader has a provable scaled-isometry structure, and RGB probabilities cover the full value domain without enumerating it. Residual-derived uncertainty is trained and evaluated—not assumed calibrated.**

## References and provenance

[1] User-supplied `README(20260926-065240).md`, “Type & Value Embeddings (Goodbye, Giant Tables).” Sources of the shared TYPE/VALUE architecture, quaternion lift, fused voting reader, and BF16-aligned RGB mapping; especially lines 73–99, 116–152, and 213–218. The residual scale formula, normalized likelihood, global discrete decoding, and safeguards here are revisions, not claims that the README already specified them.

[2] Prior generated `type_value_embeddings_proposal.md`, “Feature Proposal: Type & Value Embeddings.” Sources of the scaled-isometry proof, exact grid decoding, normalized RGB likelihood, precision counterexamples, and evaluation framework. This revision replaces its default additive TYPE embedding and separate TYPE classifier with the README's unified concatenated architecture.

[3] Shibo Wang and Pankaj Kanwar. “BFloat16: The secret to high performance on Cloud TPUs.” Google Cloud, August 23, 2019. Format semantics only; not validation of this encoder.

[4] Yi Tay et al. “Lightweight and Efficient Neural Natural Language Processing with Quaternion Networks.” ACL 2019. arXiv:1906.04393. Prior quaternion parameter sharing; not empirical validation of this feature.

[5] Chuan Guo et al. “On Calibration of Modern Neural Networks.” ICML 2017, PMLR 70:1321–1330. Calibration background, not evidence that this reader is calibrated.

[6] Google Cloud TPU documentation. “Improve your model's performance with bfloat16.” Consulted September 26, 2026. BF16 multiplication and FP32 accumulation semantics.

**Reproducibility:** `verify_unified_type_value_embeddings.py`; executed output `unified_type_value_verification_results.json`. Dependencies: NumPy, SymPy, ml_dtypes, and PyTorch. BF16 tests emulate storage rounding with FP32 arithmetic; they are not accelerator benchmarks. The gradient check covers the proposed readers and joint loss, not a trained transformer.
