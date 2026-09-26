import QNN.Model
import Mathlib.Analysis.InnerProductSpace.Calculus
import Mathlib.Analysis.Calculus.FDeriv.Star
import Mathlib.Analysis.Calculus.Deriv.Inv
import Mathlib.Analysis.SpecialFunctions.Sqrt

/-!
# Real differential of the normalized quaternion sandwich

All maps are differentiated over ℝ. No quaternion analyticity or left/right
quaternion derivative is used. The two product terms retain their distinct order;
the third term is the derivative of the norm denominator.
-/
noncomputable section
namespace QNN
open ContinuousLinearMap

/-- Derivative of w ↦ w x star(w), written as a real continuous linear map. -/
def sandwichDerivative (w x : H) : H →L[ℝ] H :=
  (mulLeftRight ℝ H (w * x) 1).comp (starL' ℝ : H ≃L[ℝ] H).toContinuousLinearMap +
    mulLeftRight ℝ H 1 (x * star w)

@[simp] theorem sandwichDerivative_apply (w x h : H) :
    sandwichDerivative w x h = w * x * star h + h * x * star w := by
  simp [sandwichDerivative, mul_assoc]

theorem sandwich_hasFDerivAt (w x : H) :
    HasFDerivAt (fun a : H => conjugate a x) (sandwichDerivative w x) w := by
  have hd := ((hasFDerivAt_id (𝕜 := ℝ) w).mul_const' x).mul'
    (hasFDerivAt_id (𝕜 := ℝ) w).star
  apply hd.congr_fderiv
  ext1 h
  simp [sandwichDerivative, ContinuousLinearMap.smul_apply,
    MulOpposite.smul_eq_mul_unop, smul_eq_mul, mul_assoc]

def normDerivative (w : H) : H →L[ℝ] ℝ := ‖w‖⁻¹ • innerSL ℝ w

theorem norm_hasFDerivAt (w : H) (hw : w ≠ 0) :
    HasFDerivAt (fun a : H => ‖a‖) (normDerivative w) w := by
  have hn : ‖w‖ ≠ 0 := norm_ne_zero_iff.mpr hw
  have hd := (hasStrictFDerivAt_norm_sq w).hasFDerivAt.sqrt (pow_ne_zero 2 hn)
  convert! hd using 1
  · funext a; exact (Real.sqrt_sq (norm_nonneg a)).symm
  · ext h
    simp [normDerivative, Real.sqrt_sq (norm_nonneg w)]
    field_simp

/-- Unsimplified form makes the inverse and norm chain rules visible. -/
def inverseNormDerivative (w : H) : H →L[ℝ] ℝ :=
  -(‖w‖ ^ 2)⁻¹ • normDerivative w

theorem inverseNorm_hasFDerivAt (w : H) (hw : w ≠ 0) :
    HasFDerivAt (fun a : H => ‖a‖⁻¹) (inverseNormDerivative w) w := by
  exact (hasDerivAt_inv (norm_ne_zero_iff.mpr hw)).comp_hasFDerivAt w (norm_hasFDerivAt w hw)

theorem inverseNormDerivative_apply (w h : H) (hw : w ≠ 0) :
    inverseNormDerivative w h = -inner ℝ w h / ‖w‖ ^ 3 := by
  have hn : ‖w‖ ≠ 0 := norm_ne_zero_iff.mpr hw
  simp [inverseNormDerivative, normDerivative]
  field_simp

/-- Raw quaternion-valued version, for a real normed-space calculus API. -/
def weightActionRaw (w x : H) : H := ‖w‖⁻¹ • conjugate w x

theorem weightActionRaw_pure (w : H) (x : Pure) :
    weightActionRaw w x = (weightAction w x : H) := rfl

def weightDerivative (w x : H) : H →L[ℝ] H :=
  ‖w‖⁻¹ • sandwichDerivative w x + (inverseNormDerivative w).smulRight (conjugate w x)

theorem weightAction_hasFDerivAt (w x : H) (hw : w ≠ 0) :
    HasFDerivAt (fun a : H => weightActionRaw a x) (weightDerivative w x) w :=
  (inverseNorm_hasFDerivAt w hw).smul (sandwich_hasFDerivAt w x)

/-- Correct ordered product terms and the missing normalization correction. -/
theorem weightDerivative_apply (w x h : H) (hw : w ≠ 0) :
    weightDerivative w x h =
      ‖w‖⁻¹ • (w * x * star h + h * x * star w) -
        (inner ℝ w h / ‖w‖ ^ 3) • (w * x * star w) := by
  simp [weightDerivative, inverseNormDerivative_apply w h hw, conjugate, sub_eq_add_neg, neg_div]

theorem weightAction_differentiableAt (w x : H) (hw : w ≠ 0) :
    DifferentiableAt ℝ (fun a => weightActionRaw a x) w :=
  (weightAction_hasFDerivAt w x hw).differentiableAt
end QNN
