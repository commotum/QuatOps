import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Data.Finset.Max
import Mathlib.Tactic.Linarith

/-! Fixed mathematical TYPE codes. Floating-point storage does not establish these hypotheses. -/

noncomputable section
namespace TypeEmbeddings

structure TypeCodebook (α : Type*) where
  code : α → EuclideanSpace ℝ (Fin 3)
  injective : Function.Injective code
  norm_one : ∀ t, ‖code t‖ = 1

variable {α : Type*} [Fintype α] [Nonempty α]

/-- A positive uniform separation bound, including a vacuous bound for one type.
This is not asserted to be the exact minimum distance in the one-type case. -/
theorem TypeCodebook.exists_separation (a : TypeCodebook α) :
    ∃ δ : ℝ, 0 < δ ∧ ∀ t u, t ≠ u → δ ≤ ‖a.code t - a.code u‖ := by
  classical
  let f : α × α → ℝ := fun p => if p.1 = p.2 then 1 else ‖a.code p.1 - a.code p.2‖
  have hf (p : α × α) : 0 < f p := by
    dsimp [f]
    split_ifs with hp
    · exact zero_lt_one
    · exact norm_pos_iff.mpr (sub_ne_zero.mpr (fun he => hp (a.injective he)))
  obtain ⟨p, _, hp⟩ := Finset.exists_min_image (Finset.univ : Finset (α × α)) f
    Finset.univ_nonempty
  refine ⟨f p, hf p, ?_⟩
  intro t u htu
  have h := hp (t, u) (Finset.mem_univ _)
  simpa only [f, if_neg htu] using h

def typeCost (a : α → EuclideanSpace ℝ (Fin 3)) (mu : EuclideanSpace ℝ (Fin 3))
    (t : α) : ℝ := ‖a t - mu‖ ^ 2

private theorem type_min_exists (a : α → EuclideanSpace ℝ (Fin 3))
    (mu : EuclideanSpace ℝ (Fin 3)) : ∃ t, ∀ u, typeCost a mu t ≤ typeCost a mu u := by
  classical
  obtain ⟨t, _, ht⟩ := Finset.exists_min_image (Finset.univ : Finset α) (typeCost a mu)
    Finset.univ_nonempty
  exact ⟨t, fun u => ht u (Finset.mem_univ u)⟩

/-- Any minimum-cost TYPE, without imposing an order on abstract type labels. -/
def nearestType (a : α → EuclideanSpace ℝ (Fin 3)) (mu : EuclideanSpace ℝ (Fin 3)) : α :=
  Classical.choose (type_min_exists a mu)

theorem nearestType_minimizes (a : α → EuclideanSpace ℝ (Fin 3))
    (mu : EuclideanSpace ℝ (Fin 3)) (t : α) :
    typeCost a mu (nearestType a mu) ≤ typeCost a mu t :=
  Classical.choose_spec (type_min_exists a mu) t

theorem nearestType_exact_of_margin (a : α → EuclideanSpace ℝ (Fin 3))
    (mu : EuclideanSpace ℝ (Fin 3)) (t : α) (δ : ℝ)
    (hsep : ∀ u, u ≠ t → δ ≤ ‖a u - a t‖)
    (hmu : ‖mu - a t‖ < δ / 2) : nearestType a mu = t := by
  by_contra hne
  have hgap := hsep (nearestType a mu) hne
  have hcost := (sq_le_sq₀ (norm_nonneg _) (norm_nonneg _)).mp
    (nearestType_minimizes a mu t)
  have ht := norm_add_le (a (nearestType a mu) - mu) (mu - a t)
  rw [sub_add_sub_cancel] at ht
  rw [norm_sub_rev (a t) mu] at hcost
  linarith only [hgap, hcost, ht, hmu]

end TypeEmbeddings
