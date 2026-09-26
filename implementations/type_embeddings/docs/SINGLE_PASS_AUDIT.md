# Single-pass proposal: full claim audit and additional Lean verification

Source: [type_value_embeddings_single_pass_proposal.md](../type_value_embeddings_single_pass_proposal.md).
SHA256: `6d2f9a911403cd75ac4746ee4057f2c1c849470878c0779637b7b68754b402e1`.
Audited against the file present on 2026-09-26 and the actual Lean modules.
The earlier RGB/unified library is retained; this audit adds the text architecture.

The core exact-arithmetic claims are correct under the stated normalization and disjoint-group
assumptions. The most material differences concern the input dimension, likelihood, reader
interpretation and retrieval guarantee. No algebraic argument establishes retrieval recall,
trained-model quality, gradients in a tensor implementation, or a hardware benefit.

## Major differences from the previous revised proposal

| Aspect | Previous RGB-first unified proposal | Single-pass text proposal |
|---|---|---|
| Initial task | RGB with a shared TYPE classifier | Ordinary TEXT only; no TYPE segment/classifier |
| MR | Fixed three-real-coordinate RGB grid and TYPE unit codes | Learned V×r dictionary of m=r/4 full quaternions |
| Encoder | One pure-imaginary input per bank | Full four-coordinate inputs in independent disjoint groups |
| Gram | S I3 per bank | diag(Sj I4), specializing to Ir when every Sj=1 |
| Readout | Least-squares location, imaginary projection, residual-derived width | Full-quaternion adjoint query, used for bias-free categorical scores |
| Likelihood/training | Finite distance kernels and residual-dependent temperature | Full-vocabulary softmax/cross-entropy; no residual confidence |
| Resolution | Exact RGB grid rounding | Approximate MIPS candidates followed by exact authoritative reranking |
| Terminal normalization | Reader before optional terminal normalization | Preserve host baseline's existing terminal-normalization convention |
| Parameters | dT+K dV+(K+1) structured-bank/gain slots | Vr+D dictionary/bank slots; index memory additional |

The previous imaginary-only RGB decoder must not be used for TEXT. Conversely, the new
MIPS decoder is not automatically a correct RGB rounding rule. The common quaternion
infrastructure remains reusable. Disjoint output groups resolve the earlier counterexample
to summing arbitrary multiple quaternion inputs into shared output coordinates.

## Claim-by-claim disposition

| Source | Claim | Audit and actual Lean evidence |
|---|---|---|
| §§1–2 | Single tied interface; unchanged token unit and host | `TiedTextModel` has one bank, one dictionary and an arbitrary host callback; `context_length` preserves token count; `tied_score` verifies tying. This is not a runtime call-count, tokenizer implementation or KV-cache theorem |
| §3 | Quaternion lift is real linear | `groupedEncoder`; full scalar/i/j/k components and right multiplication use the existing checked quaternion map |
| §3 | Independent groups prevent mixed Gram blocks | `groupedGram_apply`: the adjoint-encoder composition in group j is Sj times that group's input, with no other-group term |
| §3 | Raw normalization gives Sj=1 | `normalizedGroups_unit`; all raw group energies must be strictly positive. Zero individual weights are allowed |
| §3 | AᵀA=Ir and length/inner-product preservation | `groupedUnit_gram`, `groupedUnit_inner`, `groupedUnit_norm`; `groupedAdjoint_eq` identifies mathlib's actual real adjoint. Coordinate spaces have finranks r and D by `mrSpace_finrank` and `outputSpace_finrank` |
| §3 | A⁺=Aᵀ under unit energy | Four `groupedUnit_*`/`groupedProjection_symmetric` Moore–Penrose identities; unit round-trip and full-column rank |
| §4 | General fused energy-dividing reader is least squares | `groupedInverse_apply`, `groupedInverse_roundTrip`, `groupedResidual_orthogonal`, `grouped_reconstruction_score`, `groupedInverse_leastSquares`, `groupedInverse_unique_leastSquares`; all Sj>0 |
| §4 | Unit-energy inverse equals conjugate-sum adjoint | `groupedInverse_eq_adjoint`; exact unit energies required |
| §4 | Compact scores equal tied expanded scores | `compactScore_eq_expanded`, `textProbability_eq_expanded`, `compactGreedy_eq_expanded`; no normalization assumption, arbitrary h, same bank coefficients |
| §4 | Compact query restricts scores | `dictionaryScore_rank_le`: for fixed dictionary the attainable linear logits have dimension at most r. `text_log_odds` gives the corresponding linear log-odds identity |
| §5 | Full categorical probability and CE expression | `tokenNormalizer_pos`, `tokenProbability_sum`, `tokenPMF`, `crossEntropy_eq_neg_log_probability`, `textPMF`; finite nonempty vocabulary |
| §5 | Stable training/validation, frozen index versioning | Engineering requirements, not proved by real-valued CE. No optimizer, gradients, checkpoint serializer or stable tensor reduction supplied |
| §6 | Greedy needs no softmax denominator | `tokenProbability_order`; probability ranking equals score ranking. Exhaustive score computation is still avoided only if the index actually limits work |
| §6 | Winner inclusion makes reranking exact | `greedy_candidate_correct_iff`, `textCandidate_correct`, `TiedTextModel.indexed_correct`; nonempty valid/candidate sets, candidate subset of validity mask, consistent score function and smallest-ID ties |
| §6 | Index supplies the winner | No such guarantee is claimed or assumed as an axiom. Inclusion is an explicit hypothesis; Faiss recall and its implementation remain unverified |
| §6 | Changing metric can change ranking | Correct in general: squared L2 equals norm²(dictionary row)+norm²(query)−2 inner product. Cosine also divides by row norm. Equal row norms give an important exception; positive query-only rescaling preserves MIPS ordering |
| §6 | Shortlist sampling is truncated | `shortlist_mass_lt_one`: omitting a finite-logit token omits positive mass. No exact full-vocabulary sampler is claimed |
| §7 | Prototype settings and experiment controls | D=512,r=256,m=64,nj=2 is consistent; `prototype_parameter_count` checks its slots. Quality, recall, latency, matched-recall fairness and multi-run conclusions require experiments |
| §8 | Learned parameter count Vr+D | `textParameter_count`, `groupBank_count`; dictionary and raw bank stored slots, no biases/gains/independent reader. Not independent normalized degrees of freedom |
| §8 | Encoder/reader O(D), scoring Vr and kr | `groupProductCount_eq`, `grouped_linear_cost`, `exhaustive_score_count`, `candidate_score_count`; direct full-quaternion 16-multiplication/block slot model. Fixed-cost scalar operations; index work additional |
| §8 | Indexed total cost | O(D)+Tindex+O(kr) is a conditional cost decomposition. No vocabulary-independent bound or sublinear worst-case bound for Tindex is established |
| §8 | Index storage can erase model-weight savings | Correct; primary Faiss documentation states full coordinates plus IDs. Storage example below makes the distinction explicit |
| §9 | Use adjoint even if actual energies drift | Correct: score equality needs adjoint, not inversion. `inverse_can_reverse_ranking` proves that using the energy-dividing reader with unequal energies can reverse the winner |
| §9 | Same stored weights/dictionary, FP32 calculations, numerical tests | Necessary engineering contracts; exact real identities do not prove bitwise compact/expanded equality, gradient correctness, checkpoint consistency or BF16/FP32 runtime behavior |
| §10 | Broader TYPE/VALUE interface and RGB fallback | Existing RGB proofs retained. Multi-type routing, integer serialization and specialized likelihoods need their own contracts; no text/RGB likelihood equivalence inferred |
| §11 | Research decision and claimed quality–cost advantage | Architecture proposal and empirical question. No trained transformer/index integration or deployment benefit is established |

## Necessary qualifications and corrections

1. **Nonempty dimensions/support.** Unit group energy implies nj≥1, hence r≤D;
   `group_nonempty` and `mrWidth_le_outputWidth` prove this. Require V>0 for full CE and
   a nonempty valid support for greedy decoding. A width merely divisible by four is
   insufficient to establish a useful nonempty model.
2. **Adjoint versus inverse.** Without normalization the Gram is block diagonal with Sj,
   not Ir. The LS inverse divides by Sj, whereas categorical scoring always uses Aᵀ.
   The checked two-group example has energies 1 and 4: adjoint scores (1,2), inverse
   scores (1,1/2). Approximate unit energy is not exact inverse/adjoint equality.
3. **No identity-code guarantee.** Learned dictionary rows can collide. The theorem
   `dictionary_collision_score` shows equal rows have equal scores for every query.
   Injectivity of A only preserves distinctions already present in Q. Even a distinct
   dictionary does not guarantee that every token is a unique exposed MIPS winner.
4. **Precise capacity statement.** With fixed Q, logits and reference-token log-odds have
   rank at most r. When r<V−1, this precludes arbitrary positive categorical laws.
   Do not infer an unconditional dimensional obstruction when r≥V−1; finite logits also
   cannot assign exact zero probabilities. This is capacity analysis, not a quality result.
5. **Canonical winner, masks and empty shortlists.** Matching the maximum score need not
   match token ID at a tie. The supplied theorem uses the smallest valid ID in both
   searches. All candidate IDs must be valid; masking, overfetching, invalid/sentinel-ID
   removal and behavior if filtering empties the shortlist must be specified by an
   implementation. Retrieving some tied maximizer is weaker than canonical winner inclusion.
6. **Finite precision.** Recomputing the same mathematical dot product from the same
   dictionary bytes can still use different reduction orders. Exact score equality is
   not bitwise equality. `greedy_exact_of_score_error` gives a strongest useful conditional
   alternative: uniform score error≤epsilon and winner gap>2epsilon preserve selection.
   No numerical epsilon bound is asserted here; NaNs/nonfinite handling needs runtime semantics.
7. **Parameters versus memory.** At the prototype, P=256V+512 versus 512V, ratio
   1/2+1/V. Total dictionary+bank coefficient savings are strict only for V>2.
   No TYPE bank or residual-width gain should be added to this TEXT-only count.
   Normalizing 64 eight-real-coordinate groups removes 64 radial degrees of freedom,
   while the stored bank still has 512 coefficients; further symmetries need separate analysis.
8. **Index cost.** Candidate k is not the number of comparisons. Selected inverted lists
   can be uneven; probing all lists, or a list containing every row, can scan V vectors.
   Specify index/search parameters and measure actual work. No worst-case sublinear
   or guaranteed winner-recall theorem follows from choosing IVF-Flat.

## Checked external implementation facts

Primary [Faiss index documentation](https://github.com/facebookresearch/faiss/wiki/Faiss-indexes)
classifies IVF-Flat as cell-probe search with full vector storage and reports 4r+8 bytes
per stored vector (coordinates and ID), before index structures/centroids. It compares
queries against vectors in the selected lists; approximate search can miss the winner.
The [metric documentation](https://github.com/facebookresearch/faiss/wiki/MetricType-and-distances)
distinguishes inner product from cosine and L2. These facts were checked against current
primary documentation, not formally verified Faiss code or measured hardware.

An illustrative **dictionary/index-only** byte comparison: BF16 r=256 model dictionary
costs 512V bytes; a separate FP32 IVF-Flat copy plus IDs costs 1032V. Together these are
1544V bytes, compared with 1024V for an unindexed BF16 width-512 dictionary. This excludes
banks, backbone, index centroids/structures and temporary buffers. A baseline with its own
index must also count that index; this example is not an equal-deployment benchmark.

## Lean additions, build boundaries and validation

Additional modules are under `TypeEmbeddings/Text/`: Grouped, Decoder, Scoring,
Categorical, Retrieval, Counts, Spectral, Distribution, Resolve and Model. Their namespace
is `TypeEmbeddings.Text`; existing RGB/unified names are unchanged. The thin public root
exports both architectures. Spectral/probability/finite-order proof surfaces are separate
leaves; diagnostics never enter public or internal runtime/math dependencies.

Diagnostics/SinglePassLimitations contains the ranking-flip witness.
Diagnostics/SinglePassAxioms audits all 67 new public theorems, including the host-interface
results. Exact real/linear-map proofs do not model a production Faiss search, tensor
Hamilton products, gradient implementation or transformer attention/MLP graph.

Build and source validation results are recorded after the final combined check.
Neither proposal source nor Lean/mathlib pins are changed by the audit.
