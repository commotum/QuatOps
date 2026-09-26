# Paper map

Source: `../Quaternion_Neural_Network_and_Its_Application.md`, supplied Markdown
transcription, Isokawa, Kusakabe, Matsui and Peper. Section/equation labels below
refer to that file. Proposed names are not implemented declarations.

| Source | Kind | Proposed coverage | Current status |
| --- | --- | --- | --- |
| §2 (1) | Algebra/coordinates | Mathlib `Quaternion ℝ`; coordinate reconstruction | Planned |
| §2 (2)–(3) | Exact identities | Hamilton basis products, noncommutativity witness | Planned reuse/proofs |
| §2 (4) | Conjugation definition | `star`; component signs, involution, reversed product order | Planned |
| §2 (5) | Norm identity | `Quaternion.normSq`, norm; corrected four-component sum | Transcription correction identified |
| §2 (6) | Pure imaginary definition | Real-part-zero subspace, 3D real linear isometry | Planned |
| §3 (7) | Geometry | Unit conjugation preserves purity, norm and orientation | Planned; unit input unnecessary |
| §3 (8) | Axis-angle | Unit pure axis and cos/sin parameter yield unit quaternion | Planned; angle bound unnecessary for identity |
| §3 (9) | Geometry identity | Orthogonal Rodrigues specialization, right-handed convention | Planned |
| §3 (10) | Geometry identity | Parallel/perpendicular decomposition; full Rodrigues formula | Planned |
| §4 (11) | Neuron definition | Finite sum of norm-scaled conjugations minus pure threshold | Planned; norm notation/domain open |
| §4 (12)–(14) | Activation definition | Three coordinate applications of real sigmoid | Planned; no rotation-equivariance claim |
| §4 unnumbered error | Objective definition | Half squared Euclidean error for displayed output | Planned; aggregation unspecified |
| §4 unnumbered updates | Training definition | Four real component gradient descent updates | Planned; no explicit hidden-layer equations supplied |
| §4 BP description / §6 BP claim | Derivation claim | Real Jacobian/adjoint chain rule for a specified layered model | Independent reconstruction to investigate |
| §1/§6 learning/geometric superiority | Informal/unsupported general claims | Record limits; no implied convergence or superiority theorem | Outside proved claim set |
| §5 Tables 1–2 | Empirical evidence | Reported train/test PSNR and experimental setup | Documentation only; reproduction optional |
| §6 theoretical explanation | Speculation/future work | Record lack of detailed explanation | Not a theorem |

Table 1 total PSNR: real 26.68 dB, quaternion 26.67 dB. Table 2 total PSNR:
real 18.04 dB, quaternion 21.99 dB. These are source-reported measurements, not
formal consequences. Referenced images, initialization seeds and full training
implementation are absent from the supplied file. No experimental reproduction
or claim verification has been performed.

After implementation, replace proposed coverage with actual module/declaration
names, hypotheses, and axiom-report references; retain explicit non-theorem statuses.
