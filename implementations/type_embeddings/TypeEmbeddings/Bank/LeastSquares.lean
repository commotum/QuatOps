import TypeEmbeddings.Bank.Decoder
import Mathlib.Tactic.Abel
import Mathlib.Tactic.Linarith

/-! Exact least-squares orthogonality and Euclidean reconstruction guarantees. -/

noncomputable section
open scoped RealInnerProductSpace
namespace TypeEmbeddings

/-- The component orthogonal to the three-dimensional code space. -/
def residual {N : ℕ} (w : Fin N → Quaternion ℝ) (h : BankSpace N) : BankSpace N :=
  h - encoder w (analyticDecoder w h)

theorem residual_adjoint_zero {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (h : BankSpace N) : encoderAdjoint w (residual w h) = 0 := by
  rw [residual, map_sub, encoder_gram_apply, energy_smul_decoder w hS, sub_self]

theorem residual_orthogonal {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (h : BankSpace N) (x : RGBSpace) :
    ⟪residual w h, encoder w x⟫ = 0 := by
  rw [real_inner_comm (encoder w x), encoder_adjoint_pairing, residual_adjoint_zero w hS]
  simp

/-- Orthogonal reconstruction-score decomposition, for every real candidate. -/
theorem reconstruction_score {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (h : BankSpace N) (z : RGBSpace) :
    ‖h - encoder w z‖ ^ 2 = ‖residual w h‖ ^ 2 +
      bankEnergy w * ‖z - analyticDecoder w h‖ ^ 2 := by
  have split : h - encoder w z = residual w h + encoder w (analyticDecoder w h - z) := by
    rw [residual, map_sub]
    abel
  rw [split, norm_add_sq_real, residual_orthogonal w hS, encoder_norm_sq,
    norm_sub_rev (analyticDecoder w h) z]
  ring

theorem decoder_leastSquares {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (h : BankSpace N) (z : RGBSpace) :
    ‖residual w h‖ ^ 2 ≤ ‖h - encoder w z‖ ^ 2 := by
  rw [reconstruction_score w hS]
  exact le_add_of_nonneg_right (mul_nonneg hS.le (sq_nonneg _))

theorem decoder_unique_leastSquares {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (h : BankSpace N) (z : RGBSpace) :
    ‖h - encoder w z‖ ^ 2 = ‖residual w h‖ ^ 2 ↔ z = analyticDecoder w h := by
  rw [reconstruction_score w hS]
  constructor
  · intro heq
    have hn : ‖z - analyticDecoder w h‖ = 0 := by
      have hz : bankEnergy w * ‖z - analyticDecoder w h‖ ^ 2 = 0 := by linarith
      exact sq_eq_zero_iff.mp ((mul_eq_zero.mp hz).resolve_left (ne_of_gt hS))
    exact sub_eq_zero.mp (norm_eq_zero.mp hn)
  · intro hz
    simp [hz]

/-- Encoding scales Euclidean lengths by sqrt S. -/
theorem encoder_norm {N : ℕ} (w : Fin N → Quaternion ℝ) (x : RGBSpace) :
    ‖encoder w x‖ = Real.sqrt (bankEnergy w) * ‖x‖ := by
  apply (sq_eq_sq₀ (norm_nonneg _) (mul_nonneg (Real.sqrt_nonneg _) (norm_nonneg _))).mp
  rw [encoder_norm_sq, mul_pow, Real.sq_sqrt (bankEnergy_nonneg w)]

/-- The orthogonal projection is contractive. -/
theorem projection_norm_le {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (h : BankSpace N) :
    ‖encoder w (analyticDecoder w h)‖ ≤ ‖h‖ := by
  have split : h = residual w h + encoder w (analyticDecoder w h) := by
    rw [residual]
    abel
  have hn := norm_add_sq_real (residual w h) (encoder w (analyticDecoder w h))
  rw [residual_orthogonal w hS, ← split] at hn
  have hp := norm_nonneg (encoder w (analyticDecoder w h))
  have hh := norm_nonneg h
  nlinarith [sq_nonneg ‖residual w h‖]

/-- Absolute inverse gain: Euclidean noise is amplified by at most 1/sqrt S. -/
theorem decoder_norm_le {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (h : BankSpace N) :
    ‖analyticDecoder w h‖ ≤ ‖h‖ / Real.sqrt (bankEnergy w) := by
  have hs : 0 < Real.sqrt (bankEnergy w) := Real.sqrt_pos.mpr hS
  apply (le_div_iff₀ hs).mpr
  rw [mul_comm, ← encoder_norm]
  exact projection_norm_le w hS h

theorem decoder_error_bound {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (x : RGBSpace) (e : BankSpace N) :
    ‖analyticDecoder w (encoder w x + e) - x‖ ≤ ‖e‖ / Real.sqrt (bankEnergy w) := by
  rw [decoder_error w hS]
  exact decoder_norm_le w hS e

end TypeEmbeddings
