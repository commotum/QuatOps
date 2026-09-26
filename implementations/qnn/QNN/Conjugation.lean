import QNN.Pure

/-! Sandwich maps and basic identities shared by geometry and the forward model. -/
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

end QNN
