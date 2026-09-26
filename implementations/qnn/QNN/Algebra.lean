import Mathlib.Analysis.Quaternion
import Mathlib.Tactic

/-! Basic audited quaternion identities, using mathlib's multiplication and norm. -/
noncomputable section
namespace QNN
abbrev H := Quaternion ℝ

def basisI : H := ⟨0, 1, 0, 0⟩
def basisJ : H := ⟨0, 0, 1, 0⟩
def basisK : H := ⟨0, 0, 0, 1⟩

theorem hamilton_rules :
    basisI * basisI = -1 ∧ basisJ * basisJ = -1 ∧ basisK * basisK = -1 ∧
    basisI * basisJ = basisK ∧ basisJ * basisK = basisI ∧ basisK * basisI = basisJ ∧
    basisJ * basisI = -basisK ∧ basisK * basisJ = -basisI ∧
    basisI * basisK = -basisJ ∧ basisI * basisJ * basisK = -1 := by
  norm_num [basisI, basisJ, basisK, Quaternion.ext_iff,
    Quaternion.re_mul, Quaternion.imI_mul, Quaternion.imJ_mul, Quaternion.imK_mul,
    Quaternion.re_one, Quaternion.imI_one, Quaternion.imJ_one, Quaternion.imK_one]

theorem multiplication_not_commutative : basisI * basisJ ≠ basisJ * basisI := by
  intro h
  have := congrArg (fun q : H => q.imK) h
  norm_num [basisI, basisJ, Quaternion.imK_mul] at this

theorem conjugate_mul (a b : H) : star (a * b) = star b * star a := star_mul a b

theorem conjugate_involutive (a : H) : star (star a) = a := star_star a

/-- Corrected Eq. (5): each of the four components occurs exactly once. -/
theorem norm_sq_components (q : H) :
    ‖q‖ ^ 2 = q.re ^ 2 + q.imI ^ 2 + q.imJ ^ 2 + q.imK ^ 2 := by
  rw [pow_two, ← Quaternion.normSq_eq_norm_mul_self, Quaternion.normSq_def']

theorem norm_components (q : H) :
    ‖q‖ = Real.sqrt (q.re ^ 2 + q.imI ^ 2 + q.imJ ^ 2 + q.imK ^ 2) := by
  rw [← norm_sq_components, Real.sqrt_sq (norm_nonneg q)]

theorem mul_conjugate (q : H) : q * star q = (‖q‖ ^ 2 : ℝ) := by
  rw [Quaternion.self_mul_star, Quaternion.normSq_eq_norm_mul_self, pow_two]

theorem conjugate_mul_self (q : H) : star q * q = (‖q‖ ^ 2 : ℝ) := by
  rw [Quaternion.star_mul_self, Quaternion.normSq_eq_norm_mul_self, pow_two]
end QNN
