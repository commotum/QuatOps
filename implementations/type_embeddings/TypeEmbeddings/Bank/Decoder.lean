import TypeEmbeddings.Bank.Basic

/-! Analytic inverse and orthogonal projector for a positive-energy bank. -/

noncomputable section
open scoped RealInnerProductSpace
namespace TypeEmbeddings

/-- Scaled-adjoint readout; inverse claims explicitly require positive energy. -/
def analyticDecoder {N : ℕ} (w : Fin N → Quaternion ℝ) : BankSpace N →ₗ[ℝ] RGBSpace :=
  (bankEnergy w)⁻¹ • encoderAdjoint w

theorem decoder_fused {N : ℕ} (w : Fin N → Quaternion ℝ) (h : BankSpace N) :
    analyticDecoder w h = (bankEnergy w)⁻¹ • imaginary (∑ i, h i * star (w i)) := by
  simp [analyticDecoder, encoderAdjoint_apply]

theorem decoder_roundTrip {N : ℕ} (w : Fin N → Quaternion ℝ) (hS : 0 < bankEnergy w)
    (x : RGBSpace) : analyticDecoder w (encoder w x) = x := by
  simp [analyticDecoder, encoder_gram_apply, smul_smul, ne_of_gt hS]

theorem decoder_leftInverse {N : ℕ} (w : Fin N → Quaternion ℝ) (hS : 0 < bankEnergy w) :
    Function.LeftInverse (analyticDecoder w) (encoder w) := decoder_roundTrip w hS

theorem encoder_injective {N : ℕ} (w : Fin N → Quaternion ℝ) (hS : 0 < bankEnergy w) :
    Function.Injective (encoder w) := (decoder_leftInverse w hS).injective

theorem energy_smul_decoder {N : ℕ} (w : Fin N → Quaternion ℝ) (hS : 0 < bankEnergy w)
    (h : BankSpace N) : bankEnergy w • analyticDecoder w h = encoderAdjoint w h := by
  simp [analyticDecoder, smul_smul, ne_of_gt hS]

/-- BDB=B, the first Moore–Penrose identity. -/
theorem penrose_encoder {N : ℕ} (w : Fin N → Quaternion ℝ) (hS : 0 < bankEnergy w) :
    (encoder w).comp ((analyticDecoder w).comp (encoder w)) = encoder w := by
  apply LinearMap.ext
  intro x
  simp [decoder_roundTrip w hS]

/-- DBD=D, the second Moore–Penrose identity. -/
theorem penrose_decoder {N : ℕ} (w : Fin N → Quaternion ℝ) (hS : 0 < bankEnergy w) :
    (analyticDecoder w).comp ((encoder w).comp (analyticDecoder w)) = analyticDecoder w := by
  apply LinearMap.ext
  intro h
  simp [decoder_roundTrip w hS]

/-- BD is self-adjoint, the third Moore–Penrose identity expressed by inner products. -/
theorem penrose_projection_symmetric {N : ℕ} (w : Fin N → Quaternion ℝ)
    (h k : BankSpace N) :
    ⟪encoder w (analyticDecoder w h), k⟫ = ⟪h, encoder w (analyticDecoder w k)⟫ := by
  rw [encoder_adjoint_pairing, real_inner_comm (encoder w (analyticDecoder w k)) h,
    encoder_adjoint_pairing]
  simp only [analyticDecoder, LinearMap.smul_apply, inner_smul_left]
  rw [real_inner_comm]

/-- DB is self-adjoint, the fourth Moore–Penrose identity. -/
theorem penrose_inverse_symmetric {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (x y : RGBSpace) :
    ⟪analyticDecoder w (encoder w x), y⟫ = ⟪x, analyticDecoder w (encoder w y)⟫ := by
  simp only [decoder_roundTrip w hS]

/-- Exact perturbation identity, in real arithmetic. -/
theorem decoder_error {N : ℕ} (w : Fin N → Quaternion ℝ) (hS : 0 < bankEnergy w)
    (x : RGBSpace) (e : BankSpace N) :
    analyticDecoder w (encoder w x + e) - x = analyticDecoder w e := by
  rw [map_add, decoder_roundTrip w hS, add_sub_cancel_left]

end TypeEmbeddings
