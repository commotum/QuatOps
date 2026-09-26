# Type & Value Embeddings
## Single-pass quaternion encoding and indexed text decoding

**Status:** Proposed research architecture.  
**First experiment:** Ordinary text, one TYPE, unchanged tokenizer and transformer body.  
**Primary objective:** Avoid exhaustive vocabulary scoring during inference while retaining a single tied quaternion readout.

## 1. Executive summary

Represent each token as **(TYPE, VALUE)**. Map its VALUE into a compact **minimal representation (MR)**, expand that representation through a learned quaternion **weight bank**, and reuse the same bank to read an MR-space output from the final hidden state.

For structured values, the MR can be defined by a known function. For text, each existing token ID has a learned, multi-quaternion MR. After the transformer runs, the quaternion reader produces a **query** in that learned representation space. A non-exhaustive maximum-inner-product index retrieves candidate token IDs, and their exact model scores determine the output.

The architecture preserves the original MR, up-projection, unchanged transformer, and tied voting-reader structure.[^original] It does not add a second neural decoder, an internal autoregressive sequence, or a learned routing tree.

The central distinction is **storing a vocabulary versus scanning it**. Learned text representations remain in a dictionary; inference does not have to score every dictionary row.[^goal]

The first experiment deliberately retains full-vocabulary cross-entropy during training and validation. Its deployment target is **indexed greedy decoding**, not softmax-free training or exact sampling from the full vocabulary distribution.

## 2. Architecture

```text
Existing input token ID
          ↓
Learned minimal representation
          ↓
Quaternion up-projection
          ↓
Unchanged transformer
          ↓
Tied quaternion readout
          ↓
Query in learned MR space
          ↓
Indexed candidate retrieval + exact candidate scoring
          ↓
Existing output token ID
```

There is one transformer computation per emitted token and one parallel quaternion readout. Index traversal is a search operation, not an additional neural generator.

For the first experiment, every token has TYPE = TEXT. No TYPE classifier, TYPE segment, new tokenizer, or changed sequence length is introduced. TYPE-conditioned banks remain the broader interface, but multi-type routing is outside this experiment.

## 3. Learned representations and quaternion up-projection

Let the text vocabulary have size $V$, the transformer width be $D$, and the MR width be $r$. Both widths are multiples of four. Store a learned dictionary

$$
Q\in\mathbb R^{V\times r},
$$

whose row $q_v$ represents token $v$. Interpret each row as $m=r/4$ quaternions:

$$
q_v=(q_{v,1},\ldots,q_{v,m})\in\mathbb H^m.
$$

“Minimal representation” means the compact representation supplied to the encoder; it is not a claim of information-theoretic minimality. Token IDs remain the exact identities. The representations are learned jointly with the model, without hand-assigned semantic categories or a second identity-code system.

### Grouped expansion

Give quaternion $j$ its own group of $n_j$ output blocks and learned weights $W_{j,i}\in\mathbb H$, with

$$
D=4\sum_{j=1}^{m}n_j.
$$

Using right multiplication consistently, compute

$$
y_{v,j,i}=q_{v,j}\otimes W_{j,i},
\qquad
\boxed{e_v=Aq_v=\operatorname{vec}(y_{v,j,i}).}
$$

The groups are concatenated, not summed. This preserves the original quaternion operation while allowing text representations to contain many quaternions. Independent groups avoid the cross terms that would arise from unrestricted mixing at this encoder stage.[^groups]

The transformer may mix all coordinates normally. The grouping specifies the input/output interface; it does not constrain attention or MLPs to keep those groups separate.

### Bank normalization and inverse identity

Normalize each group's total energy to one:

$$
S_j=\sum_{i=1}^{n_j}\|W_{j,i}\|^2=1.
$$

One parameterization uses unconstrained raw weights $U$:

$$
W_{j,i}=
\frac{U_{j,i}}{\sqrt{\sum_\ell\|U_{j,\ell}\|^2}}.
$$

Initialize every group with nonzero energy and reject degenerate or nonfinite groups.

Quaternion norm multiplicativity gives $A_j^\top A_j=S_jI_4$. Because the groups are independent and normalized,

$$
\boxed{A^\top A=I_r,\qquad A^+=A^\top.}
$$

These are exact-arithmetic identities. The lift preserves MR lengths and inner products and has a tied left inverse. They do not imply exact recovery after arbitrary transformer computation.

## 4. One tied reader, interpreted as a token query

Let $h\in\mathbb R^D$ be the host model's final output vector, including its existing terminal normalization when present. Keep this convention identical in the baseline and proposed model.

Partition $h$ into the same quaternion groups used by the encoder. The general fused least-squares reader is

$$
\widehat q_j=
\frac{\sum_i h_{j,i}\otimes\overline{W_{j,i}}}{S_j}.
$$

Under unit-energy normalization, this becomes

$$
\boxed{
\widehat q_j=\sum_i h_{j,i}\otimes\overline{W_{j,i}},
\qquad \widehat q=A^\top h.
}
$$

All groups are read in parallel. No independent contraction matrix is learned.

For text, interpret $\widehat q$ as a **query for compatible tokens**, not as a Gaussian mean that should reconstruct the next token's embedding. Define the bias-free score

$$
\boxed{\ell_v=q_v^\top\widehat q.}
$$

The decisive scoring identity is

$$
\boxed{
\ell_v=q_v^\top A^\top h=(Aq_v)^\top h=e_v^\top h.
}
$$

Thus compact-space scoring is exactly the tied score defined by this model's expanded input embeddings. It is not a different approximate scoring rule. Approximation enters later, through which candidates the index returns.

Do not train text with an embedding-regression loss, a single Gaussian likelihood, residual-derived confidence, or a vote-tightening penalty. The output is trained as a categorical token scorer. A compact query still limits the score family's capacity; it does not represent every possible vocabulary distribution.

## 5. Training and validation

For the next-token target $v^*$, use ordinary full-vocabulary cross-entropy:

$$
\boxed{
\mathcal L=-\ell_{v^*}+\log\sum_{u\in\mathcal V}\exp(\ell_u).
}
$$

Train $Q$, the raw quaternion weights, and the transformer together. Compute the loss with numerically stable log-sum-exp or log-softmax.

This phase scores all $V$ tokens in the smaller $r$-dimensional space. It does **not** eliminate the training softmax. Retaining the exact objective avoids introducing negative sampling, search-dependent losses, or continuously refreshed training indexes in the first experiment.

Use the same full-vocabulary likelihood for held-out cross-entropy and perplexity. Offline exhaustive scoring provides a reference against which retrieval can be measured.

Build an index only after freezing a checkpoint. Version the checkpoint, token-ID mapping, dictionary precision, and index together; rebuild the index whenever the deployed dictionary changes.

## 6. Indexed greedy inference

The inference target is

$$
v^*=\arg\max_{v\in\mathcal V}q_v^\top\widehat q.
$$

Greedy selection does not need the softmax denominator. The expensive operation being replaced is the exhaustive vocabulary score calculation, not merely the normalization.

Use a non-exhaustive **maximum-inner-product search** index over the frozen $q_v$ vectors. Faiss supports maximum-inner-product search and approximate search with configurable accuracy–speed tradeoffs.[^faiss]

As a concrete implementation starting point, use Faiss **IVF-Flat with inner-product scoring**. It stores full vectors in inverted lists and searches selected lists rather than the complete dictionary. It adds no neural decoder and avoids adding vector-compression error to the first retrieval test.[^ivf]

For each token, retrieve a candidate set $C(\widehat q)$, initially targeting 64 candidates. Recompute their dot products from the authoritative deployed dictionary and emit

$$
\boxed{
\widetilde v=\arg\max_{v\in C(\widehat q)}q_v^\top\widehat q.
}
$$

The result equals exhaustive greedy decoding whenever the candidate set contains the exhaustive winner, subject to the same numerical precision and tie rule. The index does not guarantee that inclusion. Candidate count and search effort are separate controls; returning 64 candidates does not mean the index evaluated only 64 vectors.

Preserve the trained inner-product metric. Do not normalize dictionary rows into cosine embeddings or substitute Euclidean search after training: those changes generally alter token rankings.[^metric]

For the first benchmark, use greedy decoding with identical validity masks in all modes and no dynamic token penalties. Any later shortlist sampling must be identified as a truncated distribution, not exact full-vocabulary sampling.

## 7. First experiment

### Initial configuration

| Setting | Proposed starting value |
|---|---|
| Supported TYPEs | TEXT only |
| Tokenizer and vocabulary | Unchanged from the selected baseline |
| Transformer width $D$ | 512 |
| Learned MR width $r$ | 256 |
| Quaternions per MR | 64 |
| Expanded blocks per MR quaternion | 2 |
| Input/output tie | Shared quaternion bank and MR dictionary |
| Training objective | Full-vocabulary cross-entropy |
| Initial retrieval shortlist | 64 candidates |
| Deployment selection | Greedy candidate reranking |

These are prototype settings, not claimed optima. Start with a moderately compact MR rather than testing the smallest possible representation.

### Two trained models, four evaluation modes

Train a conventional tied-embedding transformer and the proposed quaternion-MR transformer. Keep the tokenizer, data split, backbone architecture, training-token budget, optimization schedule, and terminal-normalization convention fixed. Use bias-free tied scores in both.

| Model | Output selection | Purpose |
|---|---|---|
| Conventional tied embeddings | Exhaustive scoring | Reference quality and latency |
| Same conventional checkpoint | Indexed output-vector retrieval | Isolate the benefit of indexing alone |
| Quaternion MR model | Exhaustive compact-space scoring | Measure the representation/readout quality cost |
| Same quaternion checkpoint | Indexed MR retrieval | Evaluate the proposed deployment path |

The indexing-only control requires no additional model training. It is necessary because a conventional tied head also defines an inner-product retrieval problem.

The models are backbone-matched, not total-parameter-matched: their dictionaries have different widths. Report that difference explicitly. Use the same index family and compare retrieval settings at matched recall, rather than assuming identical settings yield equally accurate search.

### Measurements

**Model quality:** Full-vocabulary validation cross-entropy, perplexity, and next-token accuracy, including results by token frequency. Include fixed exact-copy and structured-text probes without changing tokenization.

**Retrieval quality:** On identical teacher-forced contexts, measure whether the exhaustive winning token appears in the candidate set, final top-1 agreement, and score loss relative to exhaustive selection. Evaluate free-running outputs separately so earlier retrieval errors do not confound the initial recall measurement.

**Deployment cost:** End-to-end latency per generated token, output-head latency, median and tail latency, throughput at batch size one and representative larger batches, and total memory including the index. Count device transfers, synchronization, candidate fetches, and reranking. Report index construction cost separately.

Tune index search effort on validation queries, then report held-out results. Plot latency against retrieval agreement instead of reporting one favorable operating point.

### How to interpret the result

Poor quality under exhaustive quaternion scoring points to the learned representation or constrained reader, not to retrieval. Good exhaustive quality but weak indexed agreement points to the index. Good agreement without an end-to-end speed gain means the proposed inference path has not delivered its primary benefit.

If conventional indexed decoding performs just as well at comparable cost, the evidence supports indexing rather than a quaternion-specific advantage. A favorable first result warrants further matched-cost comparisons and repeated training runs; it is not sufficient to establish a general architecture improvement.

## 8. Parameters, compute, and storage

For the TEXT model, the MR dictionary contains $Vr$ learned real coefficients. The grouped bank contains

$$
4\sum_jn_j=D
$$

stored trainable coefficients, with no separate reader matrix. Therefore,

$$
\boxed{P_{\text{dictionary+bank}}=Vr+D.}
$$

A conventional tied dictionary contains $VD$ coefficients. At $D=512$ and $r=256$, the proposed model uses approximately half as many dictionary coefficients, plus 512 bank coefficients. This is a model-parameter comparison, not a promised halving of total memory.

The encoder and reader each cost $O(D)$. Exhaustive training or validation scoring costs $O(Vr)$. Indexed inference has the form

$$
\boxed{
O(D)+T_{\text{index}}(V,r,\text{search settings})+O(kr),
}
$$

where $k$ is the returned candidate count. Index search can examine many more than $k$ vectors. There is no claimed vocabulary-independent bound for the complete decoder.

Index storage must be counted separately. In particular, duplicating a low-precision MR dictionary inside a full-precision search index can erase or reverse the model-weight memory saving. IVF-Flat stores full vector coordinates plus IDs.[^ivf]

Neither the quaternion parameter count nor the reduction in score width establishes a hardware speedup. That is measured by the four evaluation modes above.

## 9. Numerical and implementation requirements

Use standard real tensors to implement Hamilton products, with one documented component order and multiplication convention. Normalize bank energies in FP32 and retain FP32 master parameters when using mixed-precision training.

For text scoring, implement the **conjugate-sum/adjoint** form $A^\top h$ directly. It equals the normalized fused inverse in exact arithmetic and preserves the tied score definition even when finite precision leaves group energies slightly different from one. Do not independently renormalize the encoder and reader using different coefficients.

Use FP32 for reader products and reductions, stable loss normalization, and candidate reranking. Define a canonical deployed dictionary representation and derive both the index vectors and exact reference scores from it. Finite-precision score ties and ranking differences remain possible; apply one deterministic token-ID tie rule.

Before training, test quaternion multiplication/conjugation, the grouped Gram identity, encoder–reader round trips, compact versus expanded score equality, gradients, and degenerate-bank handling. Before benchmarking, test index-to-token-ID consistency, validity masks, checkpoint matching, and reranking against exhaustive scores.

These checks establish implementation correctness under specified tolerances. They do not establish language-model quality, calibrated probabilities, or exact payload prediction.

## 10. General type/value interface

The text experiment instantiates a broader interface:

$$
(\tau,v)
\xrightarrow{\phi_\tau}
q
\xrightarrow{A_\tau}
e,
\qquad
h\xrightarrow{\operatorname{Read}_\tau}
\widehat q
\xrightarrow{\operatorname{Resolve}_\tau}
\widehat v.
$$

For TEXT, $\phi_\tau$ is learned dictionary lookup and resolution is indexed inner-product retrieval. The same arrangement can be tested with character, word-part, or word vocabularies without assigning their semantic geometry manually; the first run retains its existing token unit.

For RGB, the original functional MR and direct grid conversion remain available.[^rgb] Integers and other structured payloads require their own exact representation contract and appropriate training objective. They must not be treated as arbitrary int64 values packed losslessly into one low-precision scalar.

Multi-type prediction, composite payloads, and specialized structured-value losses are later experiments. The common interface does not imply that every type shares the same likelihood or discretization rule.

## 11. Proposed decision

Implement the learned TEXT MR dictionary, grouped quaternion up-projection, tied conjugate-sum reader, full-vocabulary training loss, and frozen-checkpoint retrieval path. Leave out confidence estimators, mixture heads, learned address codes, routing trees, sequential local generators, and softmax-free training.

The first experiment asks:

> **Can a learned compact MR, expanded and read through the same quaternion bank, preserve enough text-model quality that indexed decoding improves the measured quality–cost tradeoff?**

The feature claim is deliberately bounded:

> **Type & Value Embeddings use a single tied quaternion interface for compact representations. For learned text vocabularies, indexed candidate retrieval replaces exhaustive inference scoring, while exact categorical training is retained. Text dictionaries remain; retrieval is approximate; model quality and deployment gains must be measured.**

---

## Sources and scope

The architecture above is the simplified revision requested in the conversation. The original files establish the MR, weight-bank, up-projection, and tied-reader terminology. The multi-quaternion text configuration, query-scoring objective, and first-experiment protocol are proposal decisions, not reported results. Faiss references support search behavior and implementation details, not the effectiveness of this model.

[^original]: User-supplied `README(20260926-065240).md`, “Type & Value Embeddings (Goodbye, Giant Tables),” sections “What we replace (and with what)” and “How decoding works.” This revision retains its quaternion interface but replaces its text-inappropriate mean/spread interpretation with categorical query scoring.

[^goal]: User-supplied `Pasted text(20260926-075340).txt`, opening discussion distinguishing stored text embeddings from vocabulary-wide output scoring. Its later sequential-code proposal is not adopted here.

[^groups]: Same pasted discussion, section 4, “Where quaternions fit—and how to avoid the four-dimensional bottleneck,” independent-group multi-quaternion construction.

[^faiss]: Faiss documentation, “Welcome to Faiss Documentation,” https://faiss.ai/ — maximum-inner-product search, fixed indexed vectors, and approximate search tradeoffs. Consulted September 26, 2026.

[^ivf]: Faiss official wiki, “Faiss indexes,” https://github.com/facebookresearch/faiss/wiki/Faiss-indexes — IVF-Flat storage and cell-probe search behavior. Consulted September 26, 2026.

[^metric]: Faiss official wiki, “MetricType and distances,” https://github.com/facebookresearch/faiss/wiki/MetricType-and-distances — inner product, vector norms, and distinction from cosine/Euclidean metrics. Consulted September 26, 2026.

[^rgb]: User-supplied `README(20260926-065240).md`, “bf16-friendly RGB ↔ quaternion mapping (Minimal Representation).” The functional mapping does not establish exactness of an entire mixed-precision model.
