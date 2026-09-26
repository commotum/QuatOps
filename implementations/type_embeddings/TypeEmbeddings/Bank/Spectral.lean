import TypeEmbeddings.Bank.LeastSquares
import Mathlib.Analysis.InnerProductSpace.SingularValues

/-! Spectral facts isolated from the basic encoder/decoder dependency layer. -/

noncomputable section
open scoped RealInnerProductSpace
namespace TypeEmbeddings

/-- The explicit fused numerator is mathlib's adjoint. -/
theorem encoder_adjoint {N : ℕ} (w : Fin N → Quaternion ℝ) :
    (encoder w).adjoint = encoderAdjoint w := by
  apply LinearMap.ext
  intro h
  apply ext_inner_left ℝ
  intro x
  rw [LinearMap.adjoint_inner_right, encoder_adjoint_pairing]

theorem encoder_rank {N : ℕ} (w : Fin N → Quaternion ℝ) (hS : 0 < bankEnergy w) :
    Module.finrank ℝ (LinearMap.range (encoder w)) = 3 := by
  rw [LinearMap.finrank_range_of_inj (encoder_injective w hS)]
  simp [RGBSpace]

/-- The three domain singular values are sqrt S. Entries after index 2 are zero. -/
theorem encoder_singularValue {N : ℕ} (w : Fin N → Quaternion ℝ) (i : ℕ) (hi : i < 3) :
    (encoder w).singularValues i = Real.sqrt (bankEnergy w) := by
  have hdim : Module.finrank ℝ RGBSpace = 3 := by simp [RGBSpace]
  obtain ⟨v, hv⟩ := ((encoder w).hasEigenvalue_adjoint_comp_self_sq_singularValues
    (hdim ▸ hi)).exists_hasEigenvector
  have he := Module.End.mem_eigenspace_iff.mp hv.1
  change (encoder w).adjoint (encoder w v) = (encoder w).singularValues i ^ 2 • v at he
  rw [encoder_adjoint, encoder_gram_apply] at he
  have hs := smul_left_injective ℝ hv.2 he
  apply (sq_eq_sq₀ ((encoder w).singularValues_nonneg i) (Real.sqrt_nonneg _)).mp
  rw [← hs, Real.sq_sqrt (bankEnergy_nonneg w)]

theorem encoder_singularValue_tail {N : ℕ} (w : Fin N → Quaternion ℝ)
    (i : ℕ) (hi : 3 ≤ i) : (encoder w).singularValues i = 0 := by
  apply (encoder w).singularValues_of_finrank_le
  simpa [RGBSpace] using hi

/-- Spectral condition number for the full-column-rank, three-coordinate encoder. -/
def encoderCondition {N : ℕ} (w : Fin N → Quaternion ℝ) : ℝ :=
  (encoder w).singularValues 0 / (encoder w).singularValues 2

theorem encoder_condition {N : ℕ} (w : Fin N → Quaternion ℝ) (hS : 0 < bankEnergy w) :
    encoderCondition w = 1 := by
  rw [encoderCondition, encoder_singularValue w 0 (by decide),
    encoder_singularValue w 2 (by decide)]
  exact div_self (ne_of_gt (Real.sqrt_pos.mpr hS))

/-- Euclidean operator norm of the encoder. -/
theorem encoder_opNorm {N : ℕ} (w : Fin N → Quaternion ℝ) :
    ‖(encoder w).toContinuousLinearMap‖ = Real.sqrt (bankEnergy w) :=
  ContinuousLinearMap.homothety_norm _ (encoder_norm w)

/-- Exact Euclidean operator norm of the analytic inverse. -/
theorem decoder_opNorm {N : ℕ} (w : Fin N → Quaternion ℝ) (hS : 0 < bankEnergy w) :
    ‖(analyticDecoder w).toContinuousLinearMap‖ = 1 / Real.sqrt (bankEnergy w) := by
  have hs : 0 < Real.sqrt (bankEnergy w) := Real.sqrt_pos.mpr hS
  apply le_antisymm
  · apply ContinuousLinearMap.opNorm_le_bound _ (by positivity)
    intro h
    simpa [div_eq_mul_inv, mul_comm] using decoder_norm_le w hS h
  · let x : RGBSpace := EuclideanSpace.single 0 1
    have hx : ‖x‖ = 1 := by simp [x, EuclideanSpace.single, PiLp.norm_single]
    have hbound := (analyticDecoder w).toContinuousLinearMap.le_opNorm (encoder w x)
    change ‖analyticDecoder w (encoder w x)‖ ≤
      ‖(analyticDecoder w).toContinuousLinearMap‖ * ‖encoder w x‖ at hbound
    rw [decoder_roundTrip w hS, encoder_norm, hx, mul_one] at hbound
    exact (div_le_iff₀ hs).mpr hbound

end TypeEmbeddings
