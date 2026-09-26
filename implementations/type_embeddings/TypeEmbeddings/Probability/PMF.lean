import TypeEmbeddings.Probability.Grid
import Mathlib.Probability.ProbabilityMassFunction.Constructions
import Mathlib.Data.ENNReal.BigOperators

/-! Mathlib PMF packaging of the proved finite-grid likelihood, with positive model scales. -/

noncomputable section
namespace TypeEmbeddings

abbrev PositiveScale := {s : ℝ // 0 < s}

/-- The factorized finite-grid model as an actual probability mass function. -/
def rgbPMF (mu : EuclideanSpace ℝ (Fin 3)) (s : Fin 3 → PositiveScale) : PMF RGB :=
  PMF.ofFintype (fun c => ENNReal.ofReal (rgbProbability mu (fun j => (s j).val) c)) (by
    rw [← ENNReal.ofReal_sum_of_nonneg (fun c _ => (rgbProbability_pos _ _ c).le)]
    rw [rgbProbability_sum]
    simp)

theorem rgbPMF_apply (mu : EuclideanSpace ℝ (Fin 3)) (s : Fin 3 → PositiveScale) (c : RGB) :
    rgbPMF mu s c = ENNReal.ofReal (rgbProbability mu (fun j => (s j).val) c) := rfl

theorem rgbPMF_mode (mu : EuclideanSpace ℝ (Fin 3)) (s : Fin 3 → PositiveScale) (c : RGB) :
    rgbPMF mu s c ≤ rgbPMF mu s (nearestRGB mu) := by
  apply ENNReal.ofReal_le_ofReal
  exact rgbProbability_mode mu (fun j => (s j).val) (fun j => (s j).property) c

end TypeEmbeddings
