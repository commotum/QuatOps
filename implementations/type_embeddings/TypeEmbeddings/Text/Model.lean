import TypeEmbeddings.Text.Distribution
import TypeEmbeddings.Text.Resolve

/-! A tied single-pass interface around an arbitrary unchanged host function.
The host includes its terminal normalization. No host inversion, learning-quality,
floating-point, caching or runtime call-count theorem is assumed. -/

noncomputable section
open scoped RealInnerProductSpace
namespace TypeEmbeddings.Text

variable {J : Type*} [Fintype J] {n : J → ℕ}

structure TiedTextModel (V : ℕ) where
  bank : ∀ j, Fin (n j) → Quaternion ℝ
  dictionary : Fin V → MRSpace J
  host : List (OutputSpace n) → OutputSpace n

variable {V : ℕ}

def TiedTextModel.embedding (model : TiedTextModel (n := n) V) (v : Fin V) : OutputSpace n :=
  groupedEncoder model.bank (model.dictionary v)

def TiedTextModel.embedContext (model : TiedTextModel (n := n) V)
    (context : List (Fin V)) : List (OutputSpace n) := context.map model.embedding

omit [Fintype J] in
theorem TiedTextModel.context_length (model : TiedTextModel (n := n) V)
    (context : List (Fin V)) : (model.embedContext context).length = context.length := by
  exact List.length_map model.embedding

def TiedTextModel.hidden (model : TiedTextModel (n := n) V)
    (context : List (Fin V)) : OutputSpace n := model.host (model.embedContext context)

def TiedTextModel.query (model : TiedTextModel (n := n) V)
    (context : List (Fin V)) : MRSpace J := groupedAdjoint model.bank (model.hidden context)

def TiedTextModel.score (model : TiedTextModel (n := n) V)
    (context : List (Fin V)) (v : Fin V) : ℝ := ⟪model.dictionary v, model.query context⟫

theorem TiedTextModel.tied_score (model : TiedTextModel (n := n) V)
    (context : List (Fin V)) (v : Fin V) :
    model.score context v = ⟪model.embedding v, model.hidden context⟫ :=
  compactScore_eq_expanded model.bank model.dictionary (model.hidden context) v

theorem TiedTextModel.indexed_correct (model : TiedTextModel (n := n) V)
    (context : List (Fin V)) (retrieve : MRSpace J → Finset (Fin V))
    (valid : Finset (Fin V)) (hv : valid.Nonempty)
    (hc : (retrieve (model.query context)).Nonempty)
    (hsub : retrieve (model.query context) ⊆ valid)
    (hwin : greedy (model.score context) valid hv ∈ retrieve (model.query context)) :
    greedy (model.score context) (retrieve (model.query context)) hc =
      greedy (fun v => ⟪model.embedding v, model.hidden context⟫) valid hv := by
  have he : model.score context = fun v => ⟪model.embedding v, model.hidden context⟫ := by
    funext v
    exact model.tied_score context v
  rw [greedy_candidate_correct _ valid _ hv hc hsub hwin, he]

end TypeEmbeddings.Text
