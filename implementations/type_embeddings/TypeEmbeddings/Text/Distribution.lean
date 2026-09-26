import TypeEmbeddings.Text.Scoring
import TypeEmbeddings.Text.Categorical

/-! Categorical likelihood from the tied quaternion query. -/

noncomputable section
open scoped RealInnerProductSpace
namespace TypeEmbeddings.Text

variable {J : Type*} [Fintype J] {n : J → ℕ} {V : Type*} [Fintype V] [Nonempty V]

def textPMF (w : ∀ j, Fin (n j) → Quaternion ℝ) (dictionary : V → MRSpace J)
    (h : OutputSpace n) : PMF V := tokenPMF (compactScore w dictionary h)

omit [Nonempty V] in
theorem textProbability_eq_expanded (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (dictionary : V → MRSpace J) (h : OutputSpace n) (v : V) :
    tokenProbability (compactScore w dictionary h) v =
      tokenProbability (expandedScore w dictionary h) v := by
  have he : compactScore w dictionary h = expandedScore w dictionary h := by
    funext u
    exact compactScore_eq_expanded w dictionary h u
  rw [he]

theorem text_log_odds (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (dictionary : V → MRSpace J) (h : OutputSpace n) (u v : V) :
    Real.log (tokenProbability (compactScore w dictionary h) u /
      tokenProbability (compactScore w dictionary h) v) =
        ⟪dictionary u - dictionary v, groupedAdjoint w h⟫ := by
  rw [token_log_probability_ratio, inner_sub_left]
  rfl

end TypeEmbeddings.Text
