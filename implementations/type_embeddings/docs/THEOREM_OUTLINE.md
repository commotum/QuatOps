# Proposed reusable statements

All names below are tentative namespace `TypeEmbeddings` declarations. None exist yet.
Statements are mathematical outlines, not Lean code or proof placeholders. Coordinates
are scalar/i/j/k, vectors are columns, multiplication is on the right, and norms are ℓ²
unless explicitly described as coordinate maxima.

| Proposed declaration | Intended statement and prerequisites |
|---|---|
| `channelValue`, `channelValue_injective` | φ(c)=(2c−255)/256 for c∈Fin 256; injective over ℝ |
| `channelValue_endpoints`, `channelValue_spacing` | Endpoints ±255/256; φ(b)−φ(a)=(b−a)/128 |
| `rgbGrid_card` | Cartesian channel grid has 256³=16,777,216 distinct points |
| `pureRGB`, `pureRGB_isometry` | P inserts a real zero, preserving Euclidean inner products |
| `rightMulLinear`, `rightMulMatrix_apply` | R(W) sends quaternion coordinates q to qW |
| `rightMul_adjoint`, `rightMul_gram` | Adjoint is right multiplication by conjugate W; RᵀR=‖W‖²I₄ |
| `bankEnergy_nonneg`, `bankEnergy_pos_iff` | S=Σ‖Wᵢ‖²≥0; S>0 iff some Wᵢ≠0 |
| `stacked_gram`, `encoder_gram` | AᵀA=SI₄, B=AP, BᵀB=SI₃ without a positivity hypothesis |
| `encoder_inner`, `encoder_distance_sq` | ⟨Bx,By⟩=S⟨x,y⟩; ‖Bx−By‖²=S‖x−y‖² |
| `analyticDecoder`, `decoder_leftInverse` | D=S⁻¹Bᵀ and DB=id under S>0 |
| `decoder_penrose` | BDB=B, DBD=D, BD and DB self-adjoint under S>0; hence D is the Moore–Penrose inverse |
| `encoder_injective`, `encoder_rank` | Under S>0, B injective and rank three |
| `encoder_singularValues` | First three singular values √S, remaining values zero under S>0 |
| `encoder_condition`, `decoder_norm` | Spectral σmax/σmin=1; Euclidean operator norm of D=1/√S |
| `decoder_fused` | Dh = Im(Σ hᵢ * conjugate Wᵢ)/S; no inverse of individual Wᵢ |
| `decoder_roundTrip`, `decoder_error` | D(Bx)=x and D(Bx+ε)−x=Dε under S>0 |
| `decoder_error_bound` | ‖D(Bx+ε)−x‖₂≤‖ε‖₂/√S under S>0 |
| `decoder_residual_orthogonal` | h−BDh orthogonal to range B |
| `reconstruction_score` | ‖h−Bz‖²=‖h−BDh‖²+S‖z−Dh‖² for any real z |
| `decoder_unique_leastSquares` | Dh uniquely minimizes ‖h−Bz‖² over all real z when S>0 |
| `nearestChannel`, `nearestChannel_minimizes` | Smallest-index finite argmin minimizes channel distance; clipping and specified rounding equivalent |
| `nearestRGB_global_minimizer` | Product of three nearest-channel choices minimizes ‖h−Bφ(c)‖² over all RGB |
| `nearestRGB_exact_of_margin` | If maxⱼ|μⱼ−φ(cⱼ)|<1/256, decoded RGB equals c |
| `nearestRGB_exact_of_noise` | If h=Bφ(c)+ε and ‖ε‖₂<√S/256, decoded RGB equals c |
| `channelNormalizer_pos`, `channelProbability_sum` | For s>0, Z=Σ exp(−(φ(a)−μ)²/(2s²))>0 and normalized channel weights sum to one |
| `rgbProbability_sum`, `rgbProbability_mode` | Product distribution sums to one over all RGB; independent nearest choices are joint modes |
| `typedJoint_sum` | Optional: normalized type prior and each finite conditional imply normalized joint distribution |
| `coreCoefficient_count`, `baseline_counts` | Cardinalities of coefficient index sets: bank 4N=d, baselines 3d,6d,2d,8d; counts exclude other heads/biases |
| `encoder_cost`, `decoder_cost` | Explicit straight-line/loop cost model grows linearly with N and hence d; no wall-clock claim |
| `channelValue_dyadic`, `channelValue_bf16` | Later: exact dyadic representation; actual BF16 representability only under a defined format semantics |
| `wrongCode_zeroResidual` | A code for a distinct RGB has zero residual and wrong decoded target; requires S>0 |

For W=(a,b,c,d), the candidate right matrix is
[[a,−b,−c,−d],[b,a,d,−c],[c,−d,a,b],[d,c,−b,a]].
This orientation must be checked against mathlib multiplication during stage 1.

Optional Gaussian covariance and unbiased residual variance require a formal isotropic
noise law and finite second moments; they are later work, not prerequisites for the core.
Multiple-input extensions require a new full Gram calculation or independent disjoint
banks; do not reuse the single-input statement without establishing its hypotheses.
