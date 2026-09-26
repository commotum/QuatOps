import TypeEmbeddings.Text.Grouped

/-! The compact-space query gives the exact tied expanded-embedding scores. -/

noncomputable section
open scoped RealInnerProductSpace
namespace TypeEmbeddings.Text

variable {J : Type*} [Fintype J] {n : J → ℕ} {V : Type*}

def compactScore (w : ∀ j, Fin (n j) → Quaternion ℝ) (dictionary : V → MRSpace J)
    (h : OutputSpace n) (v : V) : ℝ := ⟪dictionary v, groupedAdjoint w h⟫

def expandedScore (w : ∀ j, Fin (n j) → Quaternion ℝ) (dictionary : V → MRSpace J)
    (h : OutputSpace n) (v : V) : ℝ := ⟪groupedEncoder w (dictionary v), h⟫

/-- Exact score equality holds for arbitrary energies, including degenerate groups.
No claim of identical floating-point reduction order is made. -/
theorem compactScore_eq_expanded (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (dictionary : V → MRSpace J) (h : OutputSpace n) (v : V) :
    compactScore w dictionary h v = expandedScore w dictionary h v :=
  (groupedAdjoint_pairing w (dictionary v) h).symm

/-- Colliding dictionary rows are indistinguishable to this bias-free scorer. -/
theorem dictionary_collision_score (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (dictionary : V → MRSpace J) (h : OutputSpace n) (u v : V)
    (heq : dictionary u = dictionary v) :
    compactScore w dictionary h u = compactScore w dictionary h v := by
  unfold compactScore
  rw [heq]

end TypeEmbeddings.Text
