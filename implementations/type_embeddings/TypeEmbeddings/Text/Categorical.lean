import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Probability.ProbabilityMassFunction.Constructions
import Mathlib.Data.ENNReal.BigOperators

/-! Full-vocabulary categorical normalization and the exact cross-entropy identity.
This is an exact-real model, not a numerically stable tensor implementation. -/

noncomputable section
namespace TypeEmbeddings.Text

variable {V : Type*} [Fintype V] [Nonempty V]

def tokenNormalizer (score : V → ℝ) : ℝ := ∑ v, Real.exp (score v)
def tokenProbability (score : V → ℝ) (v : V) : ℝ := Real.exp (score v) / tokenNormalizer score

theorem tokenNormalizer_pos (score : V → ℝ) : 0 < tokenNormalizer score :=
  Finset.sum_pos (fun v _ => Real.exp_pos (score v)) Finset.univ_nonempty

theorem tokenProbability_pos (score : V → ℝ) (v : V) : 0 < tokenProbability score v :=
  div_pos (Real.exp_pos _) (tokenNormalizer_pos score)

theorem tokenProbability_sum (score : V → ℝ) : ∑ v, tokenProbability score v = 1 := by
  unfold tokenProbability
  rw [← Finset.sum_div]
  exact div_self (ne_of_gt (tokenNormalizer_pos score))

theorem tokenProbability_order (score : V → ℝ) (u v : V) :
    tokenProbability score u ≤ tokenProbability score v ↔ score u ≤ score v := by
  unfold tokenProbability
  rw [div_le_div_iff_of_pos_right (tokenNormalizer_pos score), Real.exp_le_exp]

def crossEntropy (score : V → ℝ) (target : V) : ℝ :=
  -score target + Real.log (tokenNormalizer score)

theorem crossEntropy_eq_neg_log_probability (score : V → ℝ) (target : V) :
    crossEntropy score target = -Real.log (tokenProbability score target) := by
  rw [tokenProbability, Real.log_div (ne_of_gt (Real.exp_pos _))
    (ne_of_gt (tokenNormalizer_pos score)), Real.log_exp]
  unfold crossEntropy
  ring

theorem token_log_probability_ratio (score : V → ℝ) (u v : V) :
    Real.log (tokenProbability score u / tokenProbability score v) = score u - score v := by
  rw [Real.log_div (ne_of_gt (tokenProbability_pos score u))
    (ne_of_gt (tokenProbability_pos score v))]
  unfold tokenProbability
  rw [Real.log_div (ne_of_gt (Real.exp_pos _)) (ne_of_gt (tokenNormalizer_pos score)),
    Real.log_div (ne_of_gt (Real.exp_pos _)) (ne_of_gt (tokenNormalizer_pos score)),
    Real.log_exp, Real.log_exp]
  ring

def tokenPMF (score : V → ℝ) : PMF V :=
  PMF.ofFintype (fun v => ENNReal.ofReal (tokenProbability score v)) (by
    rw [← ENNReal.ofReal_sum_of_nonneg (fun v _ => (tokenProbability_pos score v).le)]
    rw [tokenProbability_sum]
    simp)

theorem tokenPMF_apply (score : V → ℝ) (v : V) :
    tokenPMF score v = ENNReal.ofReal (tokenProbability score v) := rfl

/-- Omitting even one finite-logit token omits positive mass; a renormalized shortlist
therefore gives a truncated distribution, not the full-vocabulary categorical law. -/
theorem shortlist_mass_lt_one (score : V → ℝ) (candidates : Finset V)
    (missing : V) (hmissing : missing ∉ candidates) :
    ∑ v ∈ candidates, tokenProbability score v < 1 := by
  have hsum : ∑ v ∈ candidates, tokenProbability score v < ∑ v, tokenProbability score v := by
    apply Finset.sum_lt_sum_of_subset (Finset.subset_univ candidates) (Finset.mem_univ missing)
      hmissing (tokenProbability_pos score missing)
    intro v _ _
    exact (tokenProbability_pos score v).le
  rwa [tokenProbability_sum] at hsum

end TypeEmbeddings.Text
