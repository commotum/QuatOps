import Mathlib.Algebra.Quaternion
import Mathlib.Data.Real.Basic

/-! Algebraic maps for the right-quaternion encoder. No metric conventions are imposed
on coordinate functions in this module. -/

noncomputable section

namespace TypeEmbeddings

/-- Right multiplication, real linear even when the weight is zero. -/
def rightMulLinear (w : Quaternion ℝ) : Quaternion ℝ →ₗ[ℝ] Quaternion ℝ where
  toFun q := q * w
  map_add' q r := add_mul q r w
  map_smul' a q := by ext <;> simp <;> ring

/-- Embed three channel coordinates as a pure imaginary quaternion. -/
def pureRGBLinear : (Fin 3 → ℝ) →ₗ[ℝ] Quaternion ℝ where
  toFun x := ⟨0, x 0, x 1, x 2⟩
  map_add' x y := by ext <;> simp
  map_smul' a x := by ext <;> simp

/-- The three imaginary coordinates, in red/green/blue order. -/
def imaginaryLinear : Quaternion ℝ →ₗ[ℝ] (Fin 3 → ℝ) where
  toFun q := ![q.imI, q.imJ, q.imK]
  map_add' q r := by ext i; fin_cases i <;> simp
  map_smul' a q := by ext i; fin_cases i <;> simp

theorem imaginary_pureRGB (x : Fin 3 → ℝ) :
    imaginaryLinear (pureRGBLinear x) = x := by
  ext i
  fin_cases i <;> rfl

theorem rightMul_conjugate (w q : Quaternion ℝ) :
    rightMulLinear (star w) (rightMulLinear w q) = Quaternion.normSq w • q := by
  change (q * w) * star w = _
  rw [mul_assoc, Quaternion.self_mul_star, ← Quaternion.coe_commutes]
  exact Quaternion.coe_mul_eq_smul _ _

end TypeEmbeddings
