import Qrnn.InitializationCore

/-! Diagnostic boundary checks for the paper's normalization and direction law. -/

namespace Qrnn
open scoped Quaternion
noncomputable section

/-- Total zero normalization does not produce a unit direction. -/
theorem sampledDirection_zero : sampledDirection 0 = 0 := by
  simp [sampledDirection, imaginarySample, normalize]
  rfl

/-- Omitting the nonzero-direction hypothesis makes the polar norm identity false. -/
theorem zero_direction_polar_counterexample :
    ‖polarWeight 1 (Real.pi / 2) (sampledDirection 0)‖ ^ 2 = 0 ∧ (1 : ℝ) ^ 2 ≠ 0 := by
  constructor
  · rw [sampledDirection_zero]
    have hz : polarWeight 1 (Real.pi / 2) 0 = 0 := by
      ext <;> simp [polarWeight, Real.cos_pi_div_two]
    rw [hz]
    simp
  · norm_num

/-- Positive-octant imaginary samples retain nonnegative direction coordinates.
Normalization alone therefore does not create a uniform full-sphere direction. -/
theorem sampledDirection_imI_nonnegative (v : Fin 3 → ℝ) (hv : 0 ≤ v 0) :
    0 ≤ (sampledDirection v).imI := by
  change 0 ≤ (‖imaginarySample v‖⁻¹ : ℝ) * v 0
  exact mul_nonneg (inv_nonneg.mpr (norm_nonneg _)) hv

end
end Qrnn
