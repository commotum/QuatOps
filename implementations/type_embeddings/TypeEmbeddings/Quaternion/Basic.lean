import TypeEmbeddings.Quaternion.Core
import Mathlib.Analysis.Quaternion

/-! Euclidean geometry of the single right-multiplication block and pure RGB insertion. -/

noncomputable section
open scoped RealInnerProductSpace

namespace TypeEmbeddings

/-- Right multiplication by the conjugate is the adjoint pairing. -/
theorem rightMul_adjoint_pairing (w q r : Quaternion ℝ) :
    ⟪rightMulLinear w q, r⟫ = ⟪q, rightMulLinear (star w) r⟫ := by
  simp only [rightMulLinear, LinearMap.coe_mk, AddHom.coe_mk,
    Quaternion.inner_def, star_mul, star_star, mul_assoc]

/-- The block scales every inner product by the squared weight norm. -/
theorem rightMul_inner (w q r : Quaternion ℝ) :
    ⟪rightMulLinear w q, rightMulLinear w r⟫ = Quaternion.normSq w * ⟪q, r⟫ := by
  rw [rightMul_adjoint_pairing, rightMul_conjugate, inner_smul_right]

theorem rightMul_norm (w q : Quaternion ℝ) :
    ‖rightMulLinear w q‖ = ‖q‖ * ‖w‖ := norm_mul q w

/-- Euclidean three-space embeds as pure imaginary quaternions. -/
def pureRGB : EuclideanSpace ℝ (Fin 3) →ₗ[ℝ] Quaternion ℝ :=
  pureRGBLinear.comp (WithLp.linearEquiv 2 ℝ (Fin 3 → ℝ)).toLinearMap

/-- Imaginary-coordinate projection in the Euclidean metric representation. -/
def imaginary : Quaternion ℝ →ₗ[ℝ] EuclideanSpace ℝ (Fin 3) :=
  (WithLp.linearEquiv 2 ℝ (Fin 3 → ℝ)).symm.toLinearMap.comp imaginaryLinear

theorem pureRGB_inner (x y : EuclideanSpace ℝ (Fin 3)) :
    ⟪pureRGB x, pureRGB y⟫ = ⟪x, y⟫ := by
  simp [pureRGB, pureRGBLinear, Quaternion.inner_def, PiLp.inner_apply,
    Fin.sum_univ_three, RCLike.inner_apply]
  ring

theorem pureRGB_norm (x : EuclideanSpace ℝ (Fin 3)) : ‖pureRGB x‖ = ‖x‖ := by
  rw [norm_eq_sqrt_real_inner, norm_eq_sqrt_real_inner, pureRGB_inner]

theorem imaginary_pure (x : EuclideanSpace ℝ (Fin 3)) : imaginary (pureRGB x) = x := by
  change WithLp.toLp 2 (imaginaryLinear (pureRGBLinear (WithLp.ofLp x))) = x
  rw [imaginary_pureRGB]

theorem pureRGB_adjoint_pairing (x : EuclideanSpace ℝ (Fin 3)) (q : Quaternion ℝ) :
    ⟪pureRGB x, q⟫ = ⟪x, imaginary q⟫ := by
  simp [pureRGB, pureRGBLinear, imaginary, imaginaryLinear, Quaternion.inner_def,
    PiLp.inner_apply, Fin.sum_univ_three, RCLike.inner_apply]
  ring

end TypeEmbeddings
