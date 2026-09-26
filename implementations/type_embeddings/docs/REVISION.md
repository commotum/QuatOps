# Revised proposal migration — 2026-09-26

Active source: [`type_value_embeddings_revised_proposal.md`](../type_value_embeddings_revised_proposal.md).
SHA256: `da2d012ff531f71a199a23c010b9ce027605139298c9ca8e691d1b64615f9d1e`.
Original [`type_value_embeddings_proposal.md`](../type_value_embeddings_proposal.md)
remains provenance. Neither source file was modified.

| Aspect | Original design / current reusable code | Revised default / remaining obligation |
|---|---|---|
| TYPE interface | Additive type embedding, separate classifier | Fixed distinct unit codebook, shared quaternion TYPE bank, concatenated segments |
| Segment widths | One RGB bank of width d | D=dT+dV; each width a positive multiple of four; both banks independently require S>0 |
| Width | Three fixed learned channel scales; optional dense predictor | One residual-derived scalar variance per bank, positive fixed floor and softplus gain |
| Likelihood | General factorized channel likelihood | Common-scale RGB specialization, finite TYPE likelihood and normalized typed joint |
| Score interpretation | Least-squares decomposition proved | Probability equivalence to reconstruction Gibbs scores at T(h)=2S s²(h) still needed |
| RGB ties | Existing decoder is half-down/smallest-index | Revised proposal explicitly requires ties-to-even; compatibility proof pending |
| Learned counts | d bank coefficients; scale predictors counted separately | dT+K dV+(K+1), including one residual gain per bank; example 514 |
| Complexity | Existing multiplication-slot O(d) proofs | Add TYPE support scoring and joint TYPE+RGB work model; heap top-k remains separate algorithm claim |
| Residual interpretation | Consistency diagnostic only | Residual changes modeled width, still not correctness, calibration or exact posterior |

Quaternion maps, Gram/pseudoinverse, spectral/error results, grid structure, score
decomposition and positive-kernel normalization remain applicable. No claim that the
new architecture or head is already implemented follows from their reuse.

The migration changes planning/documentation only. It reopens stage 3 for the required
tie convention, retains stage 4 as generic foundations, and adds stage 5 for revised
unified obligations. Stage 6 is the revised final audit. Earlier stage records are
preserved as historical evidence and explicitly labeled where scope changed.

The revised verifier `verify_unified_type_value_embeddings.py`, result JSON
`unified_type_value_verification_results.json`, and cited upstream
`README(20260926-065240).md` are absent locally. Their reported symbolic/gradient/top-k
checks remain source reports, not Lean proofs or independently rerun experiments.

## Documentation refresh scope

The continuation prompt explicitly requests implementation when invoked. A request to
revise the prompt/plan is a documentation task; it does not execute the pending stages.
Historical stage records are labeled to prevent their original completion or import-only
build results from being mistaken for revised-core coverage. Build-time requirements
preserve theorem strength and kernel checking; provisional new leaf targets are identified
as plans rather than compiled modules.
