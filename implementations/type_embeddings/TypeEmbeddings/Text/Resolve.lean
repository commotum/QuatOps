import TypeEmbeddings.Text.Scoring
import TypeEmbeddings.Text.Retrieval

/-! The retrieval contract specialized to tied quaternion text scores. -/

noncomputable section
namespace TypeEmbeddings.Text

variable {J : Type*} [Fintype J] {n : J → ℕ} {V : ℕ}

theorem compactGreedy_eq_expanded (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (dictionary : Fin V → MRSpace J) (h : OutputSpace n)
    (valid : Finset (Fin V)) (hv : valid.Nonempty) :
    greedy (compactScore w dictionary h) valid hv =
      greedy (expandedScore w dictionary h) valid hv := by
  have he : compactScore w dictionary h = expandedScore w dictionary h := by
    funext v
    exact compactScore_eq_expanded w dictionary h v
  rw [he]

theorem textCandidate_correct (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (dictionary : Fin V → MRSpace J) (h : OutputSpace n)
    (valid candidates : Finset (Fin V)) (hv : valid.Nonempty) (hc : candidates.Nonempty)
    (hsub : candidates ⊆ valid)
    (hwin : greedy (compactScore w dictionary h) valid hv ∈ candidates) :
    greedy (compactScore w dictionary h) candidates hc =
      greedy (expandedScore w dictionary h) valid hv := by
  rw [greedy_candidate_correct _ valid candidates hv hc hsub hwin,
    compactGreedy_eq_expanded]

end TypeEmbeddings.Text
