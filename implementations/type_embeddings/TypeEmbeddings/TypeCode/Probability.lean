import TypeEmbeddings.TypeCode.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring

/-! Normalized finite TYPE likelihood; equal-norm codes have dot-product logits. -/

noncomputable section
open scoped RealInnerProductSpace
namespace TypeEmbeddings

variable {α : Type*} [Fintype α] [Nonempty α]

def typeKernel (a : α → EuclideanSpace ℝ (Fin 3))
    (mu : EuclideanSpace ℝ (Fin 3)) (v : ℝ) (t : α) : ℝ :=
  Real.exp (-typeCost a mu t / (2 * v))

def typeNormalizer (a : α → EuclideanSpace ℝ (Fin 3))
    (mu : EuclideanSpace ℝ (Fin 3)) (v : ℝ) : ℝ := ∑ t, typeKernel a mu v t

def typeProbability (a : α → EuclideanSpace ℝ (Fin 3))
    (mu : EuclideanSpace ℝ (Fin 3)) (v : ℝ) (t : α) : ℝ :=
  typeKernel a mu v t / typeNormalizer a mu v

omit [Fintype α] [Nonempty α] in
theorem typeKernel_pos (a : α → EuclideanSpace ℝ (Fin 3))
    (mu : EuclideanSpace ℝ (Fin 3)) (v : ℝ) (t : α) : 0 < typeKernel a mu v t :=
  Real.exp_pos _

theorem typeNormalizer_pos (a : α → EuclideanSpace ℝ (Fin 3))
    (mu : EuclideanSpace ℝ (Fin 3)) (v : ℝ) : 0 < typeNormalizer a mu v := by
  exact Finset.sum_pos (fun t _ => typeKernel_pos a mu v t) Finset.univ_nonempty

theorem typeProbability_pos (a : α → EuclideanSpace ℝ (Fin 3))
    (mu : EuclideanSpace ℝ (Fin 3)) (v : ℝ) (t : α) : 0 < typeProbability a mu v t :=
  div_pos (typeKernel_pos a mu v t) (typeNormalizer_pos a mu v)

theorem typeProbability_sum (a : α → EuclideanSpace ℝ (Fin 3))
    (mu : EuclideanSpace ℝ (Fin 3)) (v : ℝ) : ∑ t, typeProbability a mu v t = 1 := by
  unfold typeProbability
  rw [← Finset.sum_div]
  exact div_self (ne_of_gt (typeNormalizer_pos a mu v))

theorem typeProbability_mode (a : α → EuclideanSpace ℝ (Fin 3))
    (mu : EuclideanSpace ℝ (Fin 3)) (v : ℝ) (hv : 0 < v) (t : α) :
    typeProbability a mu v t ≤ typeProbability a mu v (nearestType a mu) := by
  apply div_le_div_of_nonneg_right _ (typeNormalizer_pos a mu v).le
  apply Real.exp_le_exp.mpr
  exact div_le_div_of_nonneg_right (neg_le_neg (nearestType_minimizes a mu t))
    (mul_pos (by norm_num) hv).le

omit [Fintype α] [Nonempty α] in
/-- Equal squared norms yield a candidate-independent logit offset. -/
theorem type_logits_equal_norm (a : α → EuclideanSpace ℝ (Fin 3))
    (mu : EuclideanSpace ℝ (Fin 3)) (v κ : ℝ) (hv : v ≠ 0)
    (ha : ∀ t, ‖a t‖ ^ 2 = κ) (t : α) :
    -typeCost a mu t / (2 * v) =
      ⟪a t, mu⟫ / v - (κ + ‖mu‖ ^ 2) / (2 * v) := by
  rw [typeCost, norm_sub_sq_real, ha t]
  field_simp
  ring

end TypeEmbeddings
