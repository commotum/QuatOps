import TypeEmbeddings.TypeCode.Probability
import Mathlib.Probability.ProbabilityMassFunction.Constructions
import Mathlib.Data.ENNReal.BigOperators

/-! TYPE likelihood as a mathlib PMF, with an explicitly positive kernel variance. -/

noncomputable section
namespace TypeEmbeddings

variable {α : Type*} [Fintype α] [Nonempty α]

def typePMF (a : α → EuclideanSpace ℝ (Fin 3)) (mu : EuclideanSpace ℝ (Fin 3))
    (v : {v : ℝ // 0 < v}) : PMF α :=
  PMF.ofFintype (fun t => ENNReal.ofReal (typeProbability a mu v.val t)) (by
    rw [← ENNReal.ofReal_sum_of_nonneg (fun t _ => (typeProbability_pos _ _ _ t).le)]
    rw [typeProbability_sum]
    simp)

theorem typePMF_apply (a : α → EuclideanSpace ℝ (Fin 3)) (mu : EuclideanSpace ℝ (Fin 3))
    (v : {v : ℝ // 0 < v}) (t : α) :
    typePMF a mu v t = ENNReal.ofReal (typeProbability a mu v.val t) := rfl

theorem typePMF_mode (a : α → EuclideanSpace ℝ (Fin 3)) (mu : EuclideanSpace ℝ (Fin 3))
    (v : {v : ℝ // 0 < v}) (t : α) :
    typePMF a mu v t ≤ typePMF a mu v (nearestType a mu) :=
  ENNReal.ofReal_le_ofReal (typeProbability_mode a mu v.val v.property t)

end TypeEmbeddings
