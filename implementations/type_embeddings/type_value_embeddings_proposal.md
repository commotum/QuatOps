# Feature Proposal: Type & Value Embeddings
## Structured value encoders and tied quaternion readouts for large discrete domains

**Status:** Proposed for an RGB-first prototype. The encoder/decoder identities and numerical representation have been verified; model quality, calibration, and hardware speedups remain experimental.

## 1. Executive summary

Introduce a typed-value path in which a structured token is represented as **(TYPE, VALUE)** rather than requiring an independent vocabulary entry for every possible value. Each value is first mapped to a compact **minimal representation (MR)**, then lifted into the model dimension by a learned **up-projection**, or structured embedding encoder. This retains the central feature proposed in the supplied V1–V3 drafts. [1]

For RGB, use three normalized channel coordinates, packaged as a purely imaginary quaternion. Expand this quaternion into the model dimension using a bank of quaternion weights. Reuse those weights in a closed-form, least-squares output reader.

The resulting RGB value encoder and tied point-estimate reader require **d learned real coefficients**, independent of the 16,777,216 possible colors. Their essential mathematical property is a scaled-isometry identity, which gives a simple pseudoinverse, controlled conditioning, and exact recovery of an unmodified code in exact arithmetic.

This is not an inverse of the transformer, a guarantee of exact BF16 end-to-end prediction, or a source of automatically calibrated confidence. For probabilistic generation, add an explicitly normalized, type-specific value distribution. Preserve the conventional text path.

## 2. Problem and scope

A hypothetical row-per-value RGB table has

\[
|\mathcal V_{\mathrm{RGB}}|=256^3=16{,}777{,}216
\]

rows. At \(d=512\), one embedding table would contain

\[
256^3\cdot512=8{,}589{,}934{,}592
\]

parameters: **16 GiB in BF16**, before optimizer states or other model components. Retrieving one input row is already \(O(d)\); the expensive output operation is scoring all rows, ordinarily \(O(|\mathcal V|d)\) for a dense vocabulary head.

This is a comparison against atomic enumeration, **not a claim that existing tokenizers must enumerate every color or integer**. Subword tokenization already represents text compositionally. The proposed advantage is explicit type semantics and a compact value interface, with potential sequence-length benefits that must be measured. [2]

For signed int64, the range is

\[
-2^{63}\le n\le2^{63}-1,
\]

containing **\(2^{64}=18{,}446{,}744{,}073{,}709{,}551{,}616\) distinct values**. Approximately \(9.22\times10^{18}\) describes the positive range limit, not the total number of values.

The initial implementation supports RGB. Other types require their own exact payload representation, encoder, and output likelihood; they do not automatically inherit the single-quaternion RGB construction.

## 3. Model interface

Represent a structured token as

\[
z=(\tau,v),\qquad x=\phi_\tau(v),
\]

where \(\tau\) identifies the type and \(\phi_\tau\) is its deterministic MR mapping. The input embedding is

\[
e(z)=t_\tau+E_\tau(x),
\]

with learned type embedding \(t_\tau\in\mathbb R^d\). Position handling remains part of the host architecture.

Factor the next-token distribution as

\[
p(\tau,v\mid H)=p(\tau\mid H)\,p_\tau(v\mid H),
\]

where \(H\) is the preceding context. A small type classifier selects among supported typed payloads and the ordinary text path. The text branch retains its vocabulary head; the RGB branch uses the structured reader below.

Train the value branch for the ground-truth type. At generation time, sampling the type and then its conditional value implements the joint distribution exactly. Beam scores must include both log-probability terms; greedy type selection alone is not guaranteed to maximize the joint probability.

The parser must receive explicit typed fields or apply a documented, reversible recognition rule. Preserve ordinary text when interpretation is ambiguous. Exact numeric recovery does not preserve original spelling, capitalization, or formatting unless those are retained separately.

## 4. RGB minimal representation

For each channel \(c\in\{0,\ldots,255\}\), define

\[
\phi(c)=\frac{2c-255}{256}.
\]

Then

\[
x=(\phi(r),\phi(g),\phi(b))^\top\in\mathbb R^3,
\qquad q=Px=(0,x_1,x_2,x_3)^\top\in\mathbb H,
\]

where \(P\) inserts a zero real component.

The grid has endpoints \(-255/256\) and \(255/256\), with spacing

\[
\Delta=\frac1{128}.
\]

BF16 has seven explicitly stored fraction bits and an implicit leading bit for normal values. Every grid point is exactly representable: its numerator has magnitude at most 255, requiring at most eight significant binary digits, and division by 256 is a power-of-two scaling. [3]

“Minimal representation” here means the compact, channel-preserving model input—not a claim of bit-optimal storage. RGB contains 24 bits of information. The quaternion container uses four BF16 slots, or 64 bits, of which one slot is a fixed zero. An ordinary three-coordinate real encoder is therefore an essential comparison.

Construct the grid using signed integer or FP32 arithmetic before casting, avoiding unsigned-byte overflow. Exact grid representation does not imply that subsequent projections and transformer operations are exact.

## 5. Quaternion up-projection and its verified inverse

Let \(d=4N\). For one type, learn \(N\) quaternion weights

\[
W_1,\ldots,W_N\in\mathbb H.
\]

Use right multiplication consistently:

\[
y_i=q\otimes W_i,
\qquad E(x)=\operatorname{vec}(y_1,\ldots,y_N)=Bx.
\]

Each weight contains four real coefficients. The encoder therefore has

\[
4N=d
\]

learned real coefficients: **128 quaternions, or 512 real coefficients, when \(d=512\)**. Quaternion parameter sharing is established in earlier neural-network work; this proposal applies it to a typed-value interface and tied reader. [4]

### Scaled-isometry identity

Let \(R(W_i)\) be the real \(4\times4\) matrix representing \(q\mapsto q\otimes W_i\), and define

\[
A=\begin{bmatrix}R(W_1)\\\vdots\\R(W_N)\end{bmatrix},
\qquad B=AP,
\qquad S=\sum_{i=1}^{N}\|W_i\|^2.
\]

Quaternion norm multiplicativity gives

\[
R(W_i)^\top R(W_i)=\|W_i\|^2I_4.
\]

Consequently,

\[
A^\top A=SI_4,
\qquad\boxed{B^\top B=SI_3}.
\]

For \(S>0\), \(B\) has full column rank and

\[
\boxed{B^+=\frac1S B^\top},\qquad B^+B=I_3.
\]

All three singular values equal \(\sqrt S\); the spectral condition number is one. Thus the encoder is injective and perfectly conditioned with respect to relative directional distortion. Its absolute inverse gain is still \(1/\sqrt S\), so vanishing total weight energy must be prevented.

This structure imposes a real restriction:

\[
\|E(x)-E(x')\|^2=S\|x-x'\|^2.
\]

All RGB value embeddings lie in a three-dimensional subspace, translated by the type embedding. Increasing \(d\) adds a redundant code, not independent learnable embeddings for millions of colors. The code preserves Euclidean channel geometry up to scale; it does not establish a perceptual color metric.

## 6. Output decoding and exact RGB discretization

Let \(h\in\mathbb R^d\) be the state supplied to the RGB reader, partitioned into quaternion blocks \(h_i\). Define the least-squares location

\[
\boxed{
\mu=\frac{\operatorname{Im}\!\left(\sum_{i=1}^N h_i\otimes\overline{W_i}\right)}{S}
=B^+h.
}
\]

Here \(\operatorname{Im}\) returns the three imaginary coordinates. It enforces the RGB constraint that the reconstructed quaternion's real component is zero.

This is the unique minimizer of

\[
\min_{x\in\mathbb R^3}\|h-Bx\|^2.
\]

If individual \(W_i\ne0\), the formula can be interpreted as a norm-weighted fusion of inverse-transformed block votes. **Implement the fused expression directly.** It avoids division by individual weight norms and remains valid when some weights are zero, provided \(S>0\).

An individual quaternion inversion uses constant-size arithmetic, but reading and combining \(N\) blocks costs **\(O(d)\)**, not \(O(1)\).

### Exactness and error bound

For an unmodified code, \(h=Bx\), the decoder returns \(\mu=x\) in exact arithmetic. For

\[
h=Bx+\varepsilon,
\]

its error obeys

\[
\mu-x=B^+\varepsilon,
\qquad\|\mu-x\|_2\le\frac{\|\varepsilon\|_2}{\sqrt S}.
\]

The nearest-grid RGB prediction is

\[
\boxed{
\widehat c_j=\operatorname{clip}_{[0,255]}
\left(\operatorname{round}\!\left(\frac{256\mu_j+255}{2}\right)\right).
}
\]

Declare a consistent half-way tie rule. Correct recovery is guaranteed whenever

\[
\|\mu-x\|_\infty<\frac1{256}.
\]

A sufficient, more conservative condition is \(\|\varepsilon\|_2<\sqrt S/256\).

### No local candidate cube is needed

For any RGB candidate \(c\), least-squares orthogonality yields

\[
\boxed{
\|h-B\phi(c)\|^2
=\|h-B\mu\|^2+S\|\phi(c)-\mu\|^2.
}
\]

The first term is constant across candidates. The second separates by channel. Independent rounding and clipping therefore find the **global** minimum reconstruction-error RGB value—not merely a local approximation.

For exact top-k output, combine sorted channel costs with a best-first search over their sums. A fixed seven-bin neighborhood per channel is unnecessary for top-1 and is not a general top-k guarantee.

None of these identities invert attention, MLPs, normalization, or arbitrary transformer computation. End-to-end training must make the chosen output state useful to this reader. The exact round-trip theorem applies to the defined code, not every possible final hidden state.

## 7. Probabilistic generation and uncertainty

A point estimate and a reconstruction residual are not a complete next-token distribution. The first probabilistic implementation should use a **factorized finite-grid Gaussian-shaped distribution**:

\[
p(c\mid h,\mathrm{RGB})=\prod_{j=1}^{3}p_j(c_j\mid h),
\]

\[
p_j(a\mid h)=
\frac{\exp\!\left[-\frac{(\phi(a)-\mu_j)^2}{2s_j^2}\right]}
{\sum_{b=0}^{255}\exp\!\left[-\frac{(\phi(b)-\mu_j)^2}{2s_j^2}\right]},
\qquad s_j>0.
\]

This defines a normalized distribution over **all** RGB values using three 256-term normalizers. It uses small channel normalizations—not a 16,777,216-way softmax. Compute training losses using log-sum-exp and parameterize each scale as a positive floor plus softplus of an unconstrained coefficient.

For this distribution, independent nearest-grid decoding is also the joint RGB mode. The location \(\mu\) is not necessarily the discrete distribution's expectation, and \(s_j\) is a kernel scale, not necessarily its actual standard deviation, particularly near boundaries.

Start with three learned per-type scales. Input-dependent scales require an additional predictor; a dense three-output predictor adds \(3d+3\) parameters and must be included in comparisons.

This single-component distribution assumes conditional channel independence and cannot express separated alternatives such as “red or blue, but not purple.” Evaluate a small mixture or an autoregressive channel head for multimodal tasks. Discretized mixture likelihoods have prior use in PixelCNN++, although its logistic likelihood and architecture differ from this proposal. [5]

### Agreement is not calibration

Define the RGB reconstruction residual

\[
R=\|h-B\mu\|^2.
\]

Under the explicit observation model

\[
h=Bx+\varepsilon,\qquad\varepsilon\sim\mathcal N(0,\sigma^2I_d),
\]

\(\mu\) is the continuous maximum-likelihood estimator and

\[
\operatorname{Cov}(\mu\mid x)=\frac{\sigma^2}{S}I_3,
\qquad\widehat{\sigma}^2=\frac{R}{d-3}
\]

is an unbiased residual-based estimate of observation noise variance. The denominator is \(d-3\) because RGB has three fitted coordinates.

A transformer does not automatically satisfy this independent, isotropic Gaussian error model. All blocks can agree on the same wrong value: choosing \(h=Bx_{\mathrm{wrong}}\) gives \(R=0\) regardless of the true target. Therefore residual spread is a **consistency diagnostic**, not calibrated predictive confidence. Calibration must be evaluated on held-out outcomes; neural-network confidence is not calibrated by construction. [6]

## 8. Training and numerical implementation

For a target \((\tau^*,v^*)\), use

\[
\mathcal L=-\log p(\tau^*\mid H)-\log p_{\tau^*}(v^*\mid H).
\]

An RGB squared-error warm-up or auxiliary loss is optional. If the feature supports probabilistic generation, its principal value loss must train the normalized value distribution rather than only a local candidate ranking.

An optional consistency penalty is

\[
\mathcal L_{\mathrm{consistency}}=\lambda\frac{\|h-B\mu\|^2}{d}.
\]

Default \(\lambda\) to zero and test it as an ablation. It penalizes the entire component of \(h\) outside the RGB code subspace, potentially suppressing information useful to other tasks; it must not be advertised as creating confidence.

Keep the total bank energy bounded away from zero. One option is

\[
W_i=\sqrt{S_0}\frac{V_i}{\sqrt{\sum_\ell\|V_\ell\|^2}},\qquad S_0>0,
\]

with nonzero initialization and an explicit guard against a degenerate raw bank. The coefficient counts below assume a fixed normalization target, not additional independently learned block-scale parameters. Compute the decoder denominator from the actual weights used, especially after storage quantization.

Use FP32 for weight-energy calculations, decoder products and reductions, probability normalization, and final integer conversion. Maintain FP32 master weights when training with lower-precision storage. FP32 accumulation improves numerical behavior but is not an exactness guarantee; BF16 multiplication with FP32 accumulation is also an established hardware pattern. [7]

The typed reader should initially consume the final residual stream **before final normalization**, while the text branch can retain its usual normalization. This avoids an unintended fixed-norm constraint on recoverable values. Any post-normalization variant must be separately specified and tested; a learned reader gain or adapter is additional model capacity, not a free inverse.

The input type embedding is not a known additive component of an arbitrary final output state. Do not subtract it from \(h\) merely because it was added on input. A separately specified output offset can be supported, but changes the parameter count and the definition of the reader input.

## 9. Parameter counts, complexity, and fair baselines

The following counts cover only learned coefficients in the value encoder and point-estimate reader. They exclude type embeddings, the type classifier, ordinary text parameters, distribution-scale predictors, optional biases, and adapters.

| Value encoder and reader | Learned real coefficients | At d = 512 |
|---|---:|---:|
| Dense 3D real encoder; independent 3D reader | 6d | 3,072 |
| Dense 3D real encoder; tied analytic pseudoinverse | 3d | 1,536 |
| Quaternion encoder; tied analytic reader | d | 512 |
| Independent quaternion encoder and structured reader | 2d | 1,024 |
| Padded 4D real encoder; independent 4D reader | 8d | 4,096 |

Thus the proposed tied quaternion core uses **3× fewer learned coefficients than a tied 3D real core**, and **6× fewer than an untied 3D real encoder–reader pair**. The drafts' 8× comparison applies only to the padded, untied 4D baseline; it is not a general RGB or whole-model reduction.

A real-valued encoder does not inherently require a learned contraction. For any full-column-rank \(W\in\mathbb R^{d\times3}\),

\[
W^+=(W^\top W)^{-1}W^\top
\]

is a left inverse. Its inference operator can be cached, and a real encoder with orthogonal, equal-norm columns has the same scaled-transpose form. Numerically stable least-squares methods should be used rather than assuming an explicit normal-equation inverse is always the best implementation. [8]

The quaternion benefit is a compact parameterization that guarantees this structure, not exclusive access to inversion. A cached real pseudoinverse uses additional non-learned storage; report that separately from trainable parameters.

Both compact real and quaternion value readers cost \(O(d)\). Parameter sharing does not imply a matching reduction in multiplications or latency: a straightforward pure-RGB quaternion expansion uses 12 real multiplications per four-output block, the same count as an unrestricted \(4\times3\) real block. Hardware performance must be measured.

The proposed factorized RGB likelihood adds \(3\times256\) scalar scores and their normalization. This avoids a full RGB-vocabulary projection while retaining global probability normalization.

## 10. Extending the interface to int64

Do not map an arbitrary int64 into one low-precision floating-point coordinate and claim exact recovery. An exact extension should retain the 64-bit payload, for example as eight bytes with a documented signed-integer conversion and byte order.

Map each byte to an exactly representable grid and use a structured encoder that preserves all eight coordinates. The output distribution can factor autoregressively over the eight bytes:

\[
p(n\mid h)=\prod_{j=1}^{8}p(b_j\mid b_1,\ldots,b_{j-1},h).
\]

This needs small byte-level distributions rather than a \(2^{64}\)-way softmax. Exact serialization is distinct from correct model prediction.

Packing eight coordinates into two quaternions is possible, but a generic sum of multiple quaternion inputs introduces cross terms; the single-input \(B^\top B=SI\) proof no longer applies unchanged. Use independent code banks or verify the larger encoder's full-rank pseudoinverse separately. Int64 support is a later feature, not an already established consequence of the RGB prototype.

## 11. Verification results and evaluation plan

### Checks completed for this proposal

The accompanying script performs exact symbolic checks and seeded numerical tests. No transformer was trained.

| Check | Result |
|---|---|
| Quaternion block Gram identity and pure-RGB restriction | Verified symbolically |
| BF16 grid representation and channel round-trip | All 256 channel values passed; this covers all RGB combinations coordinate-wise |
| Decoder against numerical least squares | 80 trials at d = 4, 8, 32, and 512; maximum difference 1.78 × 10^-15 |
| Exact-code FP64 round-trip | Maximum coordinate error 8.88 × 10^-16 |
| Reconstruction-score decomposition | Maximum discrepancy 3.41 × 10^-13 |
| Nearest-grid decoder | 10,000 locations checked against all channel bins; one full 16,777,216-color search also matched |
| Finite-grid probability normalization | 100 contexts passed; maximum channel normalization error 2.22 × 10^-16 |
| Gaussian covariance and residual degrees of freedom | Checked with 50,000 simulated draws under the stated noise assumptions |
| “BF16-safe grid implies exact end-to-end recovery” | Disproved by an explicit counterexample |
| “Zero residual implies correct prediction” | Disproved by an explicit counterexample |

In the BF16 counterexample, the input RGB value **(237, 169, 1)** becomes **(237, 169, 0)** after BF16 storage rounding of the expanded code, despite FP32 decoder arithmetic. The grid and weights themselves are exactly representable. This is a numerical counterexample, not an estimate of error rates for a trained model or hardware kernel.

### Prototype comparisons and acceptance criteria

Compare the quaternion path against existing text serialization, a 3D real encoder with an independent reader, a tied real pseudoinverse encoder, a fixed orthonormal code, and a small categorical or autoregressive RGB head. Hold the backbone and training data constant; compare predictive quality at matched total cost, including the probability head.

Evaluate exact RGB-match accuracy, channel error, held-out value negative log-likelihood, type accuracy, confidence calibration, text-path regression, and measured end-to-end latency and memory. Include boundary colors, unseen combinations, deliberately multimodal targets, mixed text/value sequences, and FP32 versus BF16 execution.

Before rollout, require deterministic serializer round-trips, valid normalized probabilities, verified gradients, finite outputs under supported inputs, and no silent NaN or degenerate-bank handling. Set task-specific quality and performance thresholds before training. Prefer a simpler real or categorical alternative if quaternion sharing does not deliver a useful quality–cost tradeoff.

## 12. Proposed decision

Build an **RGB-first typed-value prototype** with the exact BF16-compatible MR, a normalized quaternion up-projection, the fused tied least-squares reader, and a normalized channelwise probability model. Keep the ordinary text path and benchmark against strong compact real-valued baselines.

The defensible claim is:

> Type & Value Embeddings replace a hypothetical row-per-value representation with a compact, type-conditioned encoder and structured output distribution. The RGB quaternion variant provides an O(d) tied reader, a provable scaled-isometry structure, and d learned core coefficients. Exact learned prediction, calibrated uncertainty, and deployment speedups remain empirical requirements—not consequences of quaternion inversion.

## References and provenance

[1] Supplied V1–V3 drafts, “Type & Value Embeddings,” especially the proposed interface (lines 267–271), quaternion expansion (315–321), and RGB mapping (407–431). The conditional likelihood, corrected proofs, numerical counterexamples, and evaluation requirements are additions developed for this proposal.

[2] Taku Kudo and John Richardson. “SentencePiece: A simple and language independent subword tokenizer and detokenizer for Neural Text Processing.” EMNLP System Demonstrations, 2018. DOI: 10.18653/v1/D18-2012.

[3] Shibo Wang and Pankaj Kanwar. “BFloat16: The secret to high performance on Cloud TPUs.” Google Cloud, August 23, 2019. Format semantics.

[4] Yi Tay et al. “Lightweight and Efficient Neural Natural Language Processing with Quaternion Networks.” ACL 2019. arXiv:1906.04393. Prior quaternion parameter sharing; not empirical validation of this proposal.

[5] Tim Salimans et al. “PixelCNN++: Improving the PixelCNN with Discretized Logistic Mixture Likelihood and Other Modifications.” 2017. arXiv:1701.05517. Prior structured discrete likelihoods; not the same likelihood used here.

[6] Chuan Guo et al. “On Calibration of Modern Neural Networks.” ICML 2017, PMLR 70:1321–1330. Background on predictive calibration, not evidence that this reader is calibrated.

[7] Google Cloud TPU documentation. “Improve your model's performance with bfloat16.” Numerical storage and accumulation behavior; consulted September 25, 2026.

[8] PyTorch documentation. “torch.linalg.pinv,” including its least-squares implementation guidance; consulted September 25, 2026.

**Reproducibility:** `verify_type_value_embeddings.py`; executed output: `type_value_verification_results.json`. Requirements: NumPy, SymPy, and ml_dtypes. BF16 tests emulate storage rounding with FP32 arithmetic; they are not accelerator benchmarks. All equations in the verification scope are derived above; empirical model-level claims are intentionally left for the prototype evaluation.
