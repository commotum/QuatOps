import TypeEmbeddings.RGB.Nearest
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Algebra.BigOperators.Ring.Finset

/-! A chosen factorized Gaussian-shaped finite-grid model; normalization is exact,
while independence and kernel scales are modeling assumptions. -/

noncomputable section
namespace TypeEmbeddings

def channelKernel (mu s : ℝ) (a : Channel) : ℝ := Real.exp (-channelCost mu a / (2 * s ^ 2))
def channelNormalizer (mu s : ℝ) : ℝ := ∑ a : Channel, channelKernel mu s a
def channelProbability (mu s : ℝ) (a : Channel) : ℝ := channelKernel mu s a / channelNormalizer mu s

theorem channelKernel_pos (mu s : ℝ) (a : Channel) : 0 < channelKernel mu s a := Real.exp_pos _

theorem channelNormalizer_pos (mu s : ℝ) : 0 < channelNormalizer mu s := by
  apply Finset.sum_pos
  · intro a _
    exact channelKernel_pos mu s a
  · exact Finset.univ_nonempty

theorem channelProbability_pos (mu s : ℝ) (a : Channel) : 0 < channelProbability mu s a :=
  div_pos (channelKernel_pos mu s a) (channelNormalizer_pos mu s)

theorem channelProbability_sum (mu s : ℝ) : ∑ a : Channel, channelProbability mu s a = 1 := by
  unfold channelProbability
  rw [← Finset.sum_div]
  exact div_self (ne_of_gt (channelNormalizer_pos mu s))

/-- Independent channel factors; the complete RGB grid has 256³ points. -/
def rgbProbability (mu : EuclideanSpace ℝ (Fin 3)) (s : Fin 3 → ℝ) (c : RGB) : ℝ :=
  ∏ j : Fin 3, channelProbability (mu j) (s j) (c j)

theorem rgbProbability_pos (mu : EuclideanSpace ℝ (Fin 3)) (s : Fin 3 → ℝ) (c : RGB) :
    0 < rgbProbability mu s c := Finset.prod_pos fun _ _ => channelProbability_pos _ _ _

theorem rgbProbability_sum (mu : EuclideanSpace ℝ (Fin 3)) (s : Fin 3 → ℝ) :
    ∑ c : RGB, rgbProbability mu s c = 1 := by
  unfold rgbProbability RGB
  rw [← Fintype.prod_sum]
  simp only [channelProbability_sum, Finset.prod_const_one]

theorem channelProbability_mode (mu s : ℝ) (hs : 0 < s) (a : Channel) :
    channelProbability mu s a ≤ channelProbability mu s (nearestChannel mu) := by
  apply div_le_div_of_nonneg_right _ (channelNormalizer_pos mu s).le
  apply Real.exp_le_exp.mpr
  exact div_le_div_of_nonneg_right (neg_le_neg (nearestChannel_minimizes mu a)) (by positivity)

theorem rgbProbability_mode (mu : EuclideanSpace ℝ (Fin 3)) (s : Fin 3 → ℝ)
    (hs : ∀ j, 0 < s j) (c : RGB) : rgbProbability mu s c ≤ rgbProbability mu s (nearestRGB mu) := by
  apply Finset.prod_le_prod
  · intro j _
    exact (channelProbability_pos _ _ _).le
  · intro j _
    exact channelProbability_mode (mu j) (s j) (hs j) (c j)

end TypeEmbeddings
