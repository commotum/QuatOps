import Mathlib.Probability.ProbabilityMassFunction.Constructions
import Mathlib.Data.ENNReal.BigOperators
import Mathlib.Data.Fintype.BigOperators

/-! A TYPE law and normalized finite conditional VALUE laws define a typed joint law. -/

noncomputable section
namespace TypeEmbeddings

variable {α : Type*} {β : α → Type*} [Fintype α] [∀ t, Fintype (β t)]

def typedJointProbability (p : α → ℝ) (q : ∀ t, β t → ℝ) (z : Sigma β) : ℝ :=
  p z.1 * q z.1 z.2

theorem typedJoint_sum (p : α → ℝ) (q : ∀ t, β t → ℝ)
    (hp : ∑ t, p t = 1) (hq : ∀ t, ∑ v, q t v = 1) :
    ∑ z : Sigma β, typedJointProbability p q z = 1 := by
  unfold typedJointProbability
  rw [Fintype.sum_sigma]
  simp_rw [← Finset.mul_sum, hq, mul_one]
  exact hp

theorem typedJoint_type_marginal (p : α → ℝ) (q : ∀ t, β t → ℝ)
    (hq : ∀ t, ∑ v, q t v = 1) (t : α) :
    ∑ v : β t, typedJointProbability p q ⟨t, v⟩ = p t := by
  unfold typedJointProbability
  change (∑ v : β t, p t * q t v) = p t
  rw [← Finset.mul_sum, hq, mul_one]

def typedJointPMF (p : α → ℝ) (q : ∀ t, β t → ℝ)
    (hp0 : ∀ t, 0 ≤ p t) (hq0 : ∀ t v, 0 ≤ q t v)
    (hp : ∑ t, p t = 1) (hq : ∀ t, ∑ v, q t v = 1) : PMF (Sigma β) :=
  PMF.ofFintype (fun z => ENNReal.ofReal (typedJointProbability p q z)) (by
    rw [← ENNReal.ofReal_sum_of_nonneg (fun z _ =>
      (show 0 ≤ typedJointProbability p q z from mul_nonneg (hp0 z.1) (hq0 z.1 z.2)))]
    rw [typedJoint_sum p q hp hq]
    simp)

theorem typedJointPMF_apply (p : α → ℝ) (q : ∀ t, β t → ℝ)
    (hp0 : ∀ t, 0 ≤ p t) (hq0 : ∀ t v, 0 ≤ q t v)
    (hp : ∑ t, p t = 1) (hq : ∀ t, ∑ v, q t v = 1) (z : Sigma β) :
    typedJointPMF p q hp0 hq0 hp hq z = ENNReal.ofReal (p z.1 * q z.1 z.2) := rfl

end TypeEmbeddings
