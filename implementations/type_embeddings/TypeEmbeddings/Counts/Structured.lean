import TypeEmbeddings.Counts.Basic

/-! Revised structured counts: one gain per bank; fixed codebook storage is not learned. -/

namespace TypeEmbeddings

abbrev StructuredCoefficients (NT NV K : ℕ) :=
  QuaternionCoefficients NT ⊕ ((Fin K × QuaternionCoefficients NV) ⊕ Fin (K + 1))

theorem structuredCoefficient_count (NT NV K : ℕ) :
    Fintype.card (StructuredCoefficients NT NV K) = 4 * NT + K * (4 * NV) + (K + 1) := by
  simp only [StructuredCoefficients, QuaternionCoefficients, Fintype.card_sum,
    Fintype.card_prod, Fintype.card_fin]
  ring

theorem structured_512_count : Fintype.card (StructuredCoefficients 16 112 1) = 514 := by
  rw [structuredCoefficient_count]

end TypeEmbeddings
