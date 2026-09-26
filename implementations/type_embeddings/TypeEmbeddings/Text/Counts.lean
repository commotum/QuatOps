import TypeEmbeddings.Text.Decoder
import Mathlib.Data.Fintype.Sum
import Mathlib.LinearAlgebra.Dimension.Constructions
import Mathlib.Analysis.Asymptotics.Defs

/-! Stored coefficient cardinalities and a literal scalar-multiplication-slot model.
Index overhead, model quality and hardware latency are not mathematical consequences. -/

namespace TypeEmbeddings.Text

variable {J : Type*} [Fintype J] (n : J → ℕ)

def mrWidth : ℕ := 4 * Fintype.card J
def outputWidth : ℕ := 4 * ∑ j, n j

abbrev DictionarySlots (V : ℕ) := Fin V × (J × Fin 4)
abbrev GroupBankSlots := OutputIndex n × Fin 4
abbrev TextParameterSlots (V : ℕ) := DictionarySlots (J := J) V ⊕ GroupBankSlots n
abbrev HamiltonProductSlots := OutputIndex n × (Fin 4 × Fin 4)
abbrev ExhaustiveScoreSlots (V : ℕ) := Fin V × (J × Fin 4)

theorem mrSpace_finrank : Module.finrank ℝ (MRSpace J) = mrWidth (J := J) := by
  rw [(WithLp.linearEquiv 2 ℝ (J → Quaternion ℝ)).finrank_eq, Module.finrank_pi_fintype]
  simp [Quaternion.finrank_eq_four, mrWidth, Nat.mul_comm]

theorem outputSpace_finrank : Module.finrank ℝ (OutputSpace n) = outputWidth n := by
  rw [(WithLp.linearEquiv 2 ℝ (OutputIndex n → Quaternion ℝ)).finrank_eq,
    Module.finrank_pi_fintype]
  simp [Quaternion.finrank_eq_four, outputWidth, OutputIndex, Nat.mul_comm]

theorem groupBank_count : Fintype.card (GroupBankSlots n) = outputWidth n := by
  simp [GroupBankSlots, OutputIndex, outputWidth, Nat.mul_comm]

theorem textParameter_count (V : ℕ) :
    Fintype.card (TextParameterSlots n V) = V * mrWidth (J := J) + outputWidth n := by
  rw [Fintype.card_sum, groupBank_count]
  simp only [DictionarySlots, Fintype.card_prod, Fintype.card_fin, mrWidth]
  ring

theorem mrWidth_le_outputWidth (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (hS : ∀ j, 0 < groupEnergy w j) : mrWidth (J := J) ≤ outputWidth n := by
  have hsum : (∑ _j : J, (1 : ℕ)) ≤ ∑ j, n j := by
    apply Finset.sum_le_sum
    intro j _
    exact group_nonempty w hS j
  simpa only [Finset.sum_const, Finset.card_univ, smul_eq_mul, mul_one, mrWidth, outputWidth]
    using Nat.mul_le_mul_left 4 hsum

theorem prototype_parameter_count (V : ℕ) :
    Fintype.card (TextParameterSlots (J := Fin 64) (fun _ => 2) V) = V * 256 + 512 := by
  rw [textParameter_count]
  simp [mrWidth, outputWidth]

def groupProductCount : ℕ := Fintype.card (HamiltonProductSlots n)

/-- Both direct full-quaternion encoding and adjoint reading use these 16 products per block. -/
theorem groupProductCount_eq : groupProductCount n = 4 * outputWidth n := by
  simp only [groupProductCount, HamiltonProductSlots, Fintype.card_prod, Fintype.card_fin,
    OutputIndex, Fintype.card_sigma]
  unfold outputWidth
  ring

theorem exhaustive_score_count (V : ℕ) :
    Fintype.card (ExhaustiveScoreSlots (J := J) V) = V * mrWidth (J := J) := by
  simp [ExhaustiveScoreSlots, mrWidth, Nat.mul_comm]

/-- k candidate dot products have kr multiplication slots; index search is additional. -/
theorem candidate_score_count (k : ℕ) :
    Fintype.card (Fin k × (J × Fin 4)) = k * mrWidth (J := J) := by
  simp [mrWidth, Nat.mul_comm]

open Asymptotics Filter

/-- Uniform constant-factor bound, for arbitrary finite grouping shapes. -/
theorem grouped_linear_cost :
    (fun size : J → ℕ => (groupProductCount size : ℝ)) =O[atTop]
      (fun size : J → ℕ => (outputWidth size : ℝ)) := by
  apply IsBigO.of_bound 4
  apply Filter.Eventually.of_forall
  intro size
  rw [Real.norm_of_nonneg (Nat.cast_nonneg _), Real.norm_of_nonneg (Nat.cast_nonneg _),
    groupProductCount_eq]
  norm_num

end TypeEmbeddings.Text
