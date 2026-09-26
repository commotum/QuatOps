import TypeEmbeddings.Quaternion.Basic

/-! A finite bank of right multipliers, with explicit real Euclidean output geometry. -/

noncomputable section
open scoped RealInnerProductSpace

namespace TypeEmbeddings

abbrev RGBSpace := EuclideanSpace ℝ (Fin 3)
abbrev BankSpace (N : ℕ) := PiLp 2 (fun _ : Fin N => Quaternion ℝ)

/-- Squared total bank energy. -/
def bankEnergy {N : ℕ} (w : Fin N → Quaternion ℝ) : ℝ := ∑ i, Quaternion.normSq (w i)

theorem bankEnergy_nonneg {N : ℕ} (w : Fin N → Quaternion ℝ) : 0 ≤ bankEnergy w :=
  Finset.sum_nonneg fun _ _ => Quaternion.normSq_nonneg

/-- Stack q*Wᵢ and impose the pure-imaginary input restriction. -/
def encoder {N : ℕ} (w : Fin N → Quaternion ℝ) : RGBSpace →ₗ[ℝ] BankSpace N :=
  (WithLp.linearEquiv 2 ℝ (Fin N → Quaternion ℝ)).symm.toLinearMap.comp
    (LinearMap.pi fun i => (rightMulLinear (w i)).comp pureRGB)

/-- The explicit adjoint: sum right-conjugated blocks, then take imaginary coordinates. -/
def encoderAdjoint {N : ℕ} (w : Fin N → Quaternion ℝ) : BankSpace N →ₗ[ℝ] RGBSpace :=
  imaginary.comp (∑ i : Fin N, (rightMulLinear (star (w i))).comp (PiLp.projₗ 2 _ i))

theorem encoder_apply {N : ℕ} (w : Fin N → Quaternion ℝ) (x : RGBSpace) (i : Fin N) :
    encoder w x i = pureRGB x * w i := rfl

theorem encoderAdjoint_apply {N : ℕ} (w : Fin N → Quaternion ℝ) (h : BankSpace N) :
    encoderAdjoint w h = imaginary (∑ i, h i * star (w i)) := by
  simp [encoderAdjoint, rightMulLinear]

theorem encoder_inner {N : ℕ} (w : Fin N → Quaternion ℝ) (x y : RGBSpace) :
    ⟪encoder w x, encoder w y⟫ = bankEnergy w * ⟪x, y⟫ := by
  rw [PiLp.inner_apply]
  change (∑ i, ⟪rightMulLinear (w i) (pureRGB x), rightMulLinear (w i) (pureRGB y)⟫) = _
  simp_rw [rightMul_inner, pureRGB_inner]
  exact (Finset.sum_mul _ _ _).symm

theorem encoder_adjoint_pairing {N : ℕ} (w : Fin N → Quaternion ℝ)
    (x : RGBSpace) (h : BankSpace N) : ⟪encoder w x, h⟫ = ⟪x, encoderAdjoint w h⟫ := by
  rw [PiLp.inner_apply, encoderAdjoint_apply, map_sum, inner_sum]
  apply Finset.sum_congr rfl
  intro i _
  exact (rightMul_adjoint_pairing (w i) (pureRGB x) (h i)).trans
    (pureRGB_adjoint_pairing x (h i * star (w i)))

/-- Coordinate-free BᵀB = S I₃. No positive-energy hypothesis is needed. -/
theorem encoder_gram_apply {N : ℕ} (w : Fin N → Quaternion ℝ) (x : RGBSpace) :
    encoderAdjoint w (encoder w x) = bankEnergy w • x := by
  apply ext_inner_left ℝ
  intro y
  rw [← encoder_adjoint_pairing, encoder_inner, inner_smul_right]

theorem encoder_gram {N : ℕ} (w : Fin N → Quaternion ℝ) :
    (encoderAdjoint w).comp (encoder w) = bankEnergy w • LinearMap.id := by
  apply LinearMap.ext
  intro x
  exact encoder_gram_apply w x

theorem encoder_norm_sq {N : ℕ} (w : Fin N → Quaternion ℝ) (x : RGBSpace) :
    ‖encoder w x‖ ^ 2 = bankEnergy w * ‖x‖ ^ 2 := by
  rw [← real_inner_self_eq_norm_sq, encoder_inner, real_inner_self_eq_norm_sq]

end TypeEmbeddings
