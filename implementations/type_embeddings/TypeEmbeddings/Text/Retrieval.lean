import Mathlib.Data.Finset.Max
import Mathlib.Order.Fin.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith

/-! Abstract exact reranking on finite valid token sets. No ANN recall assumption is proved. -/

noncomputable section
namespace TypeEmbeddings.Text

variable {V : ℕ}

private def maximizers (score : Fin V → ℝ) (valid : Finset (Fin V)) : Finset (Fin V) := by
  classical
  exact valid.filter fun v => ∀ u ∈ valid, score u ≤ score v

private theorem maximizers_nonempty (score : Fin V → ℝ) (valid : Finset (Fin V))
    (hv : valid.Nonempty) : (maximizers score valid).Nonempty := by
  classical
  obtain ⟨v, hv, hmax⟩ := Finset.exists_max_image valid score hv
  exact ⟨v, by simp only [maximizers, Finset.mem_filter]; exact ⟨hv, hmax⟩⟩

/-- Highest score among valid IDs, selecting the smallest ID at exact score ties. -/
def greedy (score : Fin V → ℝ) (valid : Finset (Fin V)) (hv : valid.Nonempty) : Fin V :=
  (maximizers score valid).min' (maximizers_nonempty score valid hv)

theorem greedy_mem (score : Fin V → ℝ) (valid : Finset (Fin V)) (hv : valid.Nonempty) :
    greedy score valid hv ∈ valid := by
  have h := Finset.min'_mem (maximizers score valid) (maximizers_nonempty score valid hv)
  exact (Finset.mem_filter.mp h).1

theorem greedy_maximizes (score : Fin V → ℝ) (valid : Finset (Fin V)) (hv : valid.Nonempty)
    (v : Fin V) (hv' : v ∈ valid) : score v ≤ score (greedy score valid hv) := by
  have h := Finset.min'_mem (maximizers score valid) (maximizers_nonempty score valid hv)
  exact (Finset.mem_filter.mp h).2 v hv'

theorem greedy_tie (score : Fin V → ℝ) (valid : Finset (Fin V)) (hv : valid.Nonempty)
    (v : Fin V) (hv' : v ∈ valid) (heq : score v = score (greedy score valid hv)) :
    greedy score valid hv ≤ v := by
  classical
  apply Finset.min'_le
  simp only [maximizers, Finset.mem_filter]
  refine ⟨hv', ?_⟩
  intro u hu
  rw [heq]
  exact greedy_maximizes score valid hv u hu

/-- Canonical winner inclusion, consistent scores, masks and tie rule imply exact top-1. -/
theorem greedy_candidate_correct (score : Fin V → ℝ) (valid candidates : Finset (Fin V))
    (hv : valid.Nonempty) (hc : candidates.Nonempty) (hsub : candidates ⊆ valid)
    (hwin : greedy score valid hv ∈ candidates) :
    greedy score candidates hc = greedy score valid hv := by
  have hcvalid := hsub (greedy_mem score candidates hc)
  have hle := greedy_maximizes score valid hv _ hcvalid
  have hge := greedy_maximizes score candidates hc _ hwin
  have heq := le_antisymm hle hge
  exact le_antisymm (greedy_tie score candidates hc _ hwin heq.symm)
    (greedy_tie score valid hv _ hcvalid heq)

theorem greedy_candidate_correct_iff (score : Fin V → ℝ) (valid candidates : Finset (Fin V))
    (hv : valid.Nonempty) (hc : candidates.Nonempty) (hsub : candidates ⊆ valid) :
    greedy score candidates hc = greedy score valid hv ↔ greedy score valid hv ∈ candidates := by
  constructor
  · intro heq
    rw [← heq]
    exact greedy_mem score candidates hc
  · exact greedy_candidate_correct score valid candidates hv hc hsub

theorem greedy_candidate_score_loss_nonneg (score : Fin V → ℝ)
    (valid candidates : Finset (Fin V)) (hv : valid.Nonempty) (hc : candidates.Nonempty)
    (hsub : candidates ⊆ valid) :
    0 ≤ score (greedy score valid hv) - score (greedy score candidates hc) :=
  sub_nonneg.mpr (greedy_maximizes score valid hv _ (hsub (greedy_mem score candidates hc)))

/-- A strict score gap larger than twice the error budget preserves the unique winner.
The hypothesis is an explicit uniform bound, not a derived FP32 guarantee. -/
theorem greedy_exact_of_score_error (score approximate : Fin V → ℝ)
    (valid : Finset (Fin V)) (hv : valid.Nonempty) (winner : Fin V) (hw : winner ∈ valid)
    (epsilon : ℝ) (herr : ∀ v ∈ valid, |approximate v - score v| ≤ epsilon)
    (hgap : ∀ v ∈ valid, v ≠ winner → 2 * epsilon < score winner - score v) :
    greedy approximate valid hv = winner := by
  by_contra hne
  have hm := greedy_maximizes approximate valid hv winner hw
  have hmemb := greedy_mem approximate valid hv
  have hg := hgap _ hmemb hne
  have hwerr := (abs_le.mp (herr winner hw)).1
  have hberr := (abs_le.mp (herr _ hmemb)).2
  linarith only [hm, hg, hwerr, hberr]

end TypeEmbeddings.Text
