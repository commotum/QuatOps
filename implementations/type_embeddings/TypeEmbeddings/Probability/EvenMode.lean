import TypeEmbeddings.Probability.Grid
import TypeEmbeddings.RGB.EvenRounding

/-! Even-tie decoding is a mode of the finite-grid model. -/

noncomputable section
namespace TypeEmbeddings

theorem channelProbability_even_mode (mu s : ℝ) (hs : 0 < s) (a : Channel) :
    channelProbability mu s a ≤ channelProbability mu s (nearestChannelEven mu) := by
  apply div_le_div_of_nonneg_right _ (channelNormalizer_pos mu s).le
  apply Real.exp_le_exp.mpr
  exact div_le_div_of_nonneg_right (neg_le_neg (nearestChannelEven_minimizes mu a))
    (by positivity)

theorem rgbProbability_even_mode (mu : EuclideanSpace ℝ (Fin 3)) (s : Fin 3 → ℝ)
    (hs : ∀ j, 0 < s j) (c : RGB) :
    rgbProbability mu s c ≤ rgbProbability mu s (nearestRGBEven mu) := by
  apply Finset.prod_le_prod
  · intro j _
    exact (channelProbability_pos _ _ _).le
  · intro j _
    exact channelProbability_even_mode (mu j) (s j) (hs j) (c j)

end TypeEmbeddings
