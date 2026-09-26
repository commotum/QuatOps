import QNN.Pure
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic

/-! Conjugation geometry, valid for arbitrary pure vectors (not only unit vectors). -/
noncomputable section
namespace QNN

/-- Ordered sandwich product. -/
def conjugate (a q : H) : H := a * q * star a

theorem conjugate_pure (a : H) (v : Pure) : (conjugate a v).re = 0 := by
  apply Quaternion.star_eq_neg.mp
  simp only [conjugate, star_mul, star_star, pure_star, mul_neg, neg_mul]
  rw [mul_assoc]

def conjugatePure (a : H) : Pure →ₗ[ℝ] Pure where
  toFun v := ⟨conjugate a v, conjugate_pure a v⟩
  map_add' v w := by apply pure_ext; simp [conjugate, mul_add, add_mul]
  map_smul' r v := by apply pure_ext; simp [conjugate]

@[simp] theorem coe_conjugatePure (a : H) (v : Pure) :
    (conjugatePure a v : H) = conjugate a v := rfl

theorem conjugate_norm (a q : H) : ‖conjugate a q‖ = ‖a‖ ^ 2 * ‖q‖ := by
  simp [conjugate, norm_mul]; ring

theorem unit_conjugate_norm (a : H) (ha : ‖a‖ = 1) (q : H) :
    ‖conjugate a q‖ = ‖q‖ := by rw [conjugate_norm, ha]; simp

theorem conjugate_comp (a b q : H) :
    conjugate a (conjugate b q) = conjugate (a * b) q := by
  simp only [conjugate, star_mul, mul_assoc]

theorem conjugate_real (a : H) (ha : ‖a‖ = 1) (r : ℝ) :
    conjugate a (r : H) = (r : H) := by
  rw [conjugate, Quaternion.mul_coe_eq_smul, smul_mul_assoc, mul_conjugate, ha]
  rw [← Quaternion.coe_mul_eq_smul]; simp

theorem conjugate_inverse (a : H) (ha : ‖a‖ = 1) (q : H) :
    conjugate (star a) (conjugate a q) = q := by
  rw [conjugate_comp, conjugate_mul_self, ha]
  simp [conjugate]

/-- A unit quaternion acts as a real linear isometry on the pure subspace. -/
def unitConjugation (a : H) (ha : ‖a‖ = 1) : Pure ≃ₗᵢ[ℝ] Pure :=
  { conjugatePure a with
    invFun := conjugatePure (star a)
    left_inv := by intro v; apply pure_ext; exact conjugate_inverse a ha v
    right_inv := by
      intro v; apply pure_ext
      simpa using conjugate_inverse (star a) (by rwa [Quaternion.norm_star]) v
    norm_map' := by intro v; exact unit_conjugate_norm a ha v }

theorem conjugate_mul_unit (a : H) (ha : ‖a‖ = 1) (p q : H) :
    conjugate a (p * q) = conjugate a p * conjugate a q := by
  have h : star a * a = (1 : H) := by rw [conjugate_mul_self, ha]; norm_num
  simp only [conjugate]
  calc
    a * (p * q) * star a = a * p * (star a * a) * q * star a := by rw [h]; simp [mul_assoc]
    _ = a * p * star a * (a * q * star a) := by simp only [mul_assoc]

theorem unit_conjugate_dot (a : H) (ha : ‖a‖ = 1) (u v : Pure) :
    dot (conjugatePure a u) (conjugatePure a v) = dot u v := by
  have h := (unitConjugation a ha).inner_map_map u v
  change inner ℝ (conjugatePure a u) (conjugatePure a v) = inner ℝ u v at h
  simpa only [pure_inner] using h

/-- Cross-product preservation makes the orientation convention explicit. -/
theorem unit_conjugate_cross (a : H) (ha : ‖a‖ = 1) (u v : Pure) :
    conjugatePure a (cross u v) = cross (conjugatePure a u) (conjugatePure a v) := by
  have h := conjugate_mul_unit a ha u v
  change conjugate a ((u : H) * (v : H)) =
    (conjugatePure a u : H) * (conjugatePure a v : H) at h
  rw [pure_mul, pure_mul] at h
  have hadd (p q : H) : conjugate a (p + q) = conjugate a p + conjugate a q := by
    simp [conjugate, mul_add, add_mul]
  rw [hadd, conjugate_real a ha, unit_conjugate_dot a ha] at h
  apply pure_ext
  exact add_left_cancel h

/-- Preservation of oriented volume is stronger than norm preservation alone. -/
theorem unit_conjugate_oriented_volume (a : H) (ha : ‖a‖ = 1) (u v w : Pure) :
    dot (conjugatePure a u) (cross (conjugatePure a v) (conjugatePure a w)) =
      dot u (cross v w) := by
  rw [← unit_conjugate_cross a ha, unit_conjugate_dot a ha]
/-- Axis-angle quaternion; the spatial rotation angle is twice this parameter. -/
def axisAngle (α : ℝ) (u : Pure) : H := (Real.cos α : H) + Real.sin α • (u : H)

theorem pure_unit_components (u : Pure) (hu : ‖u‖ = 1) :
    (u : H).imI ^ 2 + (u : H).imJ ^ 2 + (u : H).imK ^ 2 = 1 := by
  have h := norm_sq_components (u : H)
  change ‖(u : H)‖ = 1 at hu
  simpa [pure_re, hu] using h.symm

theorem axisAngle_unit (α : ℝ) (u : Pure) (hu : ‖u‖ = 1) :
    ‖axisAngle α u‖ = 1 := by
  have hn := pure_unit_components u hu
  have hs := Real.cos_sq_add_sin_sq α
  have hsq : ‖axisAngle α u‖ ^ 2 = 1 := by
    rw [norm_sq_components]
    simp [axisAngle, Quaternion.re_smul]
    linear_combination (Real.sin α) ^ 2 * hn + hs
  nlinarith [norm_nonneg (axisAngle α u)]

/-- Polynomial form of Rodrigues' identity, before trigonometric substitution. -/
theorem sandwich_rodrigues (c s : ℝ) (u v : Pure) (hu : ‖u‖ = 1) :
    conjugate ((c : H) + s • (u : H)) v =
      (c ^ 2 - s ^ 2) • (v : H) + (2 * c * s) • (cross u v : H) +
        (2 * s ^ 2 * dot u v) • (u : H) := by
  have hn := pure_unit_components u hu
  ext <;> simp [conjugate, Quaternion.re_mul, Quaternion.imI_mul,
    Quaternion.imJ_mul, Quaternion.imK_mul, Quaternion.re_smul,
    cross, ofVector, vector, cross_apply, dot_components]
  · ring
  · linear_combination -(s ^ 2 * (v : H).imI) * hn
  · linear_combination -(s ^ 2 * (v : H).imJ) * hn
  · linear_combination -(s ^ 2 * (v : H).imK) * hn

/-- Full Eq. (10) in Rodrigues form, for all pure input vectors. -/
theorem rodrigues (α : ℝ) (u v : Pure) (hu : ‖u‖ = 1) :
    conjugate (axisAngle α u) v =
      Real.cos (2 * α) • (v : H) + Real.sin (2 * α) • (cross u v : H) +
        ((1 - Real.cos (2 * α)) * dot u v) • (u : H) := by
  rw [axisAngle, sandwich_rodrigues _ _ u v hu]
  have hc : Real.cos (2 * α) = Real.cos α ^ 2 - Real.sin α ^ 2 := by
    rw [Real.cos_two_mul]; nlinarith [Real.cos_sq_add_sin_sq α]
  have hs : 1 - Real.cos (2 * α) = 2 * Real.sin α ^ 2 := by
    rw [hc]; nlinarith [Real.cos_sq_add_sin_sq α]
  rw [hs, hc, Real.sin_two_mul]
  congr 2 <;> ring

/-- Eq. (9) requires perpendicularity, but not a unit input vector. -/
theorem rodrigues_orthogonal (α : ℝ) (u v : Pure) (hu : ‖u‖ = 1)
    (huv : dot u v = 0) :
    conjugate (axisAngle α u) v =
      Real.cos (2 * α) • (v : H) + Real.sin (2 * α) • (cross u v : H) := by
  rw [rodrigues α u v hu, huv]; simp
end QNN
