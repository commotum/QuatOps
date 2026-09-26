import TypeEmbeddings.RGB.Nearest
import Mathlib.Algebra.Order.Round

/-! An explicit integer rounding and clipping implementation of exact nearest-grid decoding. -/

noncomputable section
namespace TypeEmbeddings

/-- Convert a real minimal-representation coordinate back to channel-index units. -/
def channelIndex (mu : ℝ) : ℝ := (256 * mu + 255) / 2

/-- Nearest integer, with halfway ties toward negative infinity. -/
def roundHalfDown (t : ℝ) : ℤ := -round (-t)

/-- Clip an integer to the valid byte interval. Negative values become zero. -/
def clipChannel (n : ℤ) : Channel := ⟨min 255 n.toNat, by omega⟩

def roundedClippedChannel (mu : ℝ) : Channel := clipChannel (roundHalfDown (channelIndex mu))

theorem roundHalfDown_interval (t : ℝ) :
    (roundHalfDown t : ℝ) - 1 / 2 < t ∧ t ≤ (roundHalfDown t : ℝ) + 1 / 2 := by
  have h := (round_eq_iff (x := -t) (n := round (-t))).mp rfl
  simp only [Set.mem_Ico] at h
  simp only [roundHalfDown, Int.cast_neg]
  constructor <;> linarith

private theorem index_distance (mu : ℝ) (a : Channel) :
    channelValue a - mu = ((a.val : ℝ) - channelIndex mu) / 128 := by
  unfold channelValue channelIndex
  ring

/-- A bounded Voronoi interval specifies the nearest channel, including the tie rule. -/
theorem nearestChannel_eq_of_interval (mu : ℝ) (c : Channel)
    (hlo : c.val ≠ 0 → (c.val : ℝ) - 1 / 2 < channelIndex mu)
    (hhi : c.val ≠ 255 → channelIndex mu ≤ (c.val : ℝ) + 1 / 2) :
    nearestChannel mu = c := by
  let a := nearestChannel mu
  have hmin := nearestChannel_minimizes mu c
  change channelCost mu a ≤ channelCost mu c at hmin
  have hnear : ((a.val : ℝ) - channelIndex mu) ^ 2 ≤
      ((c.val : ℝ) - channelIndex mu) ^ 2 := by
    unfold channelCost at hmin
    rw [index_distance, index_distance] at hmin
    nlinarith
  by_cases hac : a = c
  · exact hac
  have hv : a.val ≠ c.val := fun h => hac (Fin.ext h)
  rcases lt_or_gt_of_ne hv with hlt | hgt
  · have hc0 : c.val ≠ 0 := by omega
    have hstep : (a.val : ℝ) + 1 ≤ (c.val : ℝ) := by exact_mod_cast Nat.succ_le_of_lt hlt
    have hbound := hlo hc0
    have hp : 0 < (c.val : ℝ) - (a.val : ℝ) := by linarith
    have hq : 0 < 2 * channelIndex mu - (c.val : ℝ) - (a.val : ℝ) := by linarith
    exfalso
    nlinarith only [hnear, mul_pos hp hq]
  · have hc255 : c.val ≠ 255 := by have := a.isLt; omega
    have hstep : (c.val : ℝ) + 1 ≤ (a.val : ℝ) := by exact_mod_cast Nat.succ_le_of_lt hgt
    have hbound := hhi hc255
    have hp : 0 ≤ (a.val : ℝ) - (c.val : ℝ) := by linarith
    have hq : 0 ≤ (a.val : ℝ) + (c.val : ℝ) - 2 * channelIndex mu := by linarith
    have hreverse : ((c.val : ℝ) - channelIndex mu) ^ 2 ≤
        ((a.val : ℝ) - channelIndex mu) ^ 2 := by nlinarith only [mul_nonneg hp hq]
    have heq : channelCost mu c = channelCost mu a := by
      unfold channelCost
      rw [index_distance, index_distance, div_pow, div_pow, le_antisymm hnear hreverse]
    have htie := nearestChannel_tie mu c heq
    change a ≤ c at htie
    exact False.elim (not_le_of_gt hgt htie)

/-- Exact equivalence to clipped nearest-integer rounding with half-down ties. -/
theorem nearestChannel_eq_round_clip (mu : ℝ) :
    nearestChannel mu = roundedClippedChannel mu := by
  let n := roundHalfDown (channelIndex mu)
  have hn := roundHalfDown_interval (channelIndex mu)
  change (n : ℝ) - 1 / 2 < channelIndex mu ∧ channelIndex mu ≤ (n : ℝ) + 1 / 2 at hn
  apply nearestChannel_eq_of_interval
  · intro hc
    change min 255 n.toNat ≠ 0 at hc
    have hn0 : 0 ≤ n := by omega
    have hcast : (n.toNat : ℝ) = (n : ℝ) := by exact_mod_cast Int.toNat_of_nonneg hn0
    change ((min 255 n.toNat : ℕ) : ℝ) - 1 / 2 < channelIndex mu
    have hle : ((min 255 n.toNat : ℕ) : ℝ) ≤ (n.toNat : ℝ) := by exact_mod_cast Nat.min_le_right 255 n.toNat
    rw [hcast] at hle
    linarith [hn.1]
  · intro hc
    change min 255 n.toNat ≠ 255 at hc
    have hnat : min 255 n.toNat = n.toNat := by omega
    change ((min 255 n.toNat : ℕ) : ℝ) + 1 / 2 ≥ channelIndex mu
    rw [hnat]
    have hle : (n : ℝ) ≤ (n.toNat : ℝ) := by exact_mod_cast Int.self_le_toNat n
    linarith [hn.2]

end TypeEmbeddings
