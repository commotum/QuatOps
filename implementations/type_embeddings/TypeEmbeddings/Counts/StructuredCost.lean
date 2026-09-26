import TypeEmbeddings.Counts.Cost

/-! Conservative scalar-work model for one TYPE decision and one RGB branch.
Scalar exponentials, square roots, division and comparison each have fixed unit cost
in this model. It is not a bit-complexity or accelerator-latency theorem. -/

namespace TypeEmbeddings

/-- Fused location products, explicit reconstruction products, residual squares,
and a fixed allowance for scalar width calculations. -/
def bankSummaryWork (N : ℕ) : ℕ :=
  decoderProductCount N + encoderProductCount N + 4 * N + 16

/-- Two bank summaries, fixed work per TYPE and RGB-bin score/normalization,
and fixed final mode/conversion work. Multiple VALUE branches are not evaluated here. -/
def structuredOutputWork (NT NV types : ℕ) : ℕ :=
  bankSummaryWork NT + bankSummaryWork NV + 16 * types + 16 * 768 + 16

def structuredWorkScale (NT NV types : ℕ) : ℕ := 4 * NT + 4 * NV + types + 768

theorem bankSummaryWork_eq (N : ℕ) : bankSummaryWork N = 32 * N + 19 := by
  rw [bankSummaryWork, decoderProductCount_eq, encoderProductCount_eq]
  omega

theorem structured_output_work_bound (NT NV types : ℕ) :
    structuredOutputWork NT NV types ≤ 17 * structuredWorkScale NT NV types := by
  unfold structuredOutputWork structuredWorkScale
  rw [bankSummaryWork_eq, bankSummaryWork_eq]
  omega

open Asymptotics Filter

/-- The uniform bound proves O(dT+dV+TYPE-count+768) in the explicit scalar model. -/
theorem structured_output_cost :
    (fun n : ℕ × ℕ × ℕ => (structuredOutputWork n.1 n.2.1 n.2.2 : ℝ)) =O[atTop]
      (fun n : ℕ × ℕ × ℕ => (structuredWorkScale n.1 n.2.1 n.2.2 : ℝ)) := by
  apply IsBigO.of_bound 17
  apply Filter.Eventually.of_forall
  intro n
  have hr : (structuredOutputWork n.1 n.2.1 n.2.2 : ℝ) ≤
      17 * (structuredWorkScale n.1 n.2.1 n.2.2 : ℝ) := by
    exact_mod_cast structured_output_work_bound n.1 n.2.1 n.2.2
  simpa only [Real.norm_of_nonneg (Nat.cast_nonneg _)] using hr

end TypeEmbeddings
