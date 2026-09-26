import TypeEmbeddings.RGB.Grid
import Mathlib.Data.Finset.Max

/-! Exact bounded nearest-grid selection, with ties toward smaller channel indices. -/

noncomputable section
namespace TypeEmbeddings

/-- Squared channel distance used by the exact decoder. -/
def channelCost (mu : ℝ) (a : Channel) : ℝ := (channelValue a - mu) ^ 2

private def channelMinimizers (mu : ℝ) : Finset Channel := by
  classical
  exact Finset.univ.filter fun a => ∀ b, channelCost mu a ≤ channelCost mu b

private theorem channelMinimizers_nonempty (mu : ℝ) : (channelMinimizers mu).Nonempty := by
  classical
  obtain ⟨a, _, ha⟩ := Finset.exists_min_image (Finset.univ : Finset Channel)
    (channelCost mu) Finset.univ_nonempty
  exact ⟨a, by simp [channelMinimizers, ha]⟩

/-- Select the smallest channel among all exact nearest-grid minimizers. -/
def nearestChannel (mu : ℝ) : Channel :=
  (channelMinimizers mu).min' (channelMinimizers_nonempty mu)

theorem nearestChannel_minimizes (mu : ℝ) (a : Channel) :
    channelCost mu (nearestChannel mu) ≤ channelCost mu a := by
  classical
  have h := Finset.min'_mem (channelMinimizers mu) (channelMinimizers_nonempty mu)
  exact (Finset.mem_filter.mp h).2 a

/-- Tie convention: choose the smaller index whenever candidate costs agree. -/
theorem nearestChannel_tie (mu : ℝ) (a : Channel)
    (ha : channelCost mu a = channelCost mu (nearestChannel mu)) : nearestChannel mu ≤ a := by
  classical
  apply Finset.min'_le
  simp only [channelMinimizers, Finset.mem_filter, Finset.mem_univ, true_and]
  intro b
  rw [ha]
  exact nearestChannel_minimizes mu b

/-- Decode each RGB coordinate independently. -/
def nearestRGB (mu : EuclideanSpace ℝ (Fin 3)) : RGB := fun j => nearestChannel (mu j)

theorem nearestRGB_minimizes (mu : EuclideanSpace ℝ (Fin 3)) (c : RGB) :
    ‖rgbValue (nearestRGB mu) - mu‖ ^ 2 ≤ ‖rgbValue c - mu‖ ^ 2 := by
  rw [rgbValue_norm_sq, rgbValue_norm_sq]
  apply Finset.sum_le_sum
  intro j _
  exact nearestChannel_minimizes (mu j) (c j)

/-- Strict half-spacing implies exact recovery, independent of ties. -/
theorem nearestChannel_exact_of_margin (mu : ℝ) (c : Channel)
    (hc : |mu - channelValue c| < 1 / 256) : nearestChannel mu = c := by
  by_contra hne
  have gap := channelValue_abs_gap (nearestChannel mu) c hne
  have hcost := sq_le_sq.mp (nearestChannel_minimizes mu c)
  have ht := abs_add_le (channelValue (nearestChannel mu) - mu) (mu - channelValue c)
  rw [sub_add_sub_cancel] at ht
  rw [abs_sub_comm (channelValue c) mu] at hcost
  linarith

theorem nearestRGB_exact_of_margin (mu : EuclideanSpace ℝ (Fin 3)) (c : RGB)
    (hc : ∀ j, |mu j - channelValue (c j)| < 1 / 256) : nearestRGB mu = c := by
  funext j
  exact nearestChannel_exact_of_margin (mu j) (c j) (hc j)

end TypeEmbeddings
