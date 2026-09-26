import TypeEmbeddings.RGB.Rounding
import Mathlib.Algebra.Ring.Int.Parity

/-! Exact nearest-grid selection with the revised ties-to-even convention. -/

noncomputable section
namespace TypeEmbeddings

/-- Nearest integer; an exact halfway tie selects the even integer. -/
def roundTiesEven (t : ℝ) : ℤ :=
  if t = (roundHalfDown t : ℝ) + 1 / 2 ∧ ¬ Even (roundHalfDown t)
  then roundHalfDown t + 1 else roundHalfDown t

theorem roundTiesEven_interval (t : ℝ) :
    (roundTiesEven t : ℝ) - 1 / 2 ≤ t ∧ t ≤ (roundTiesEven t : ℝ) + 1 / 2 := by
  have h := roundHalfDown_interval t
  unfold roundTiesEven
  split_ifs with ht
  · simp only [Int.cast_add, Int.cast_one]
    constructor <;> linarith [ht.1]
  · exact ⟨h.1.le, h.2⟩

/-- The half-down lower integer is retained unless the tie requires its even successor. -/
theorem roundTiesEven_halfway (t : ℝ)
    (ht : t = (roundHalfDown t : ℝ) + 1 / 2) : Even (roundTiesEven t) := by
  unfold roundTiesEven
  split_ifs with he
  · exact even_add_one.mpr (Int.not_even_iff_odd.mp he.2)
  · by_contra hne
    exact he ⟨ht, hne⟩

theorem roundHalfDown_halfway (n : ℤ) : roundHalfDown ((n : ℝ) + 1 / 2) = n := by
  have hr : round (-((n : ℝ) + 1 / 2)) = -n := by
    apply round_eq_iff.mpr
    simp only [Set.mem_Ico, Int.cast_neg]
    constructor <;> linarith
  unfold roundHalfDown
  rw [hr, neg_neg]

/-- Explicit tie formula, valid for negative as well as positive integer indices. -/
theorem roundTiesEven_halfway_eq (n : ℤ) :
    roundTiesEven ((n : ℝ) + 1 / 2) = if Even n then n else n + 1 := by
  unfold roundTiesEven
  rw [roundHalfDown_halfway]
  by_cases he : Even n
  · simp only [he, not_true_eq_false, and_false, ite_false, ite_true]
  · simp only [he, not_false_eq_true, eq_self, and_self, ite_true, ite_false]

/-- Revised channel decoder: ties-to-even integer rounding followed by byte clipping. -/
def nearestChannelEven (mu : ℝ) : Channel :=
  clipChannel (roundTiesEven (channelIndex mu))

private theorem index_distance_even (mu : ℝ) (a : Channel) :
    channelValue a - mu = ((a.val : ℝ) - channelIndex mu) / 128 := by
  unfold channelValue channelIndex
  ring

/-- Any closed bounded Voronoi interval gives a minimizer, independently of tie choice. -/
theorem channel_minimizes_of_closed_interval (mu : ℝ) (c : Channel)
    (hlo : c.val ≠ 0 → (c.val : ℝ) - 1 / 2 ≤ channelIndex mu)
    (hhi : c.val ≠ 255 → channelIndex mu ≤ (c.val : ℝ) + 1 / 2)
    (a : Channel) : channelCost mu c ≤ channelCost mu a := by
  have hsq : ((c.val : ℝ) - channelIndex mu) ^ 2 ≤
      ((a.val : ℝ) - channelIndex mu) ^ 2 := by
    rcases lt_trichotomy a.val c.val with hlt | heq | hgt
    · have hc0 : c.val ≠ 0 := by omega
      have hstep : (a.val : ℝ) + 1 ≤ (c.val : ℝ) := by
        exact_mod_cast Nat.succ_le_of_lt hlt
      have hb := hlo hc0
      have hp : 0 ≤ (c.val : ℝ) - (a.val : ℝ) := by linarith
      have hq : 0 ≤ 2 * channelIndex mu - (c.val : ℝ) - (a.val : ℝ) := by linarith
      nlinarith only [mul_nonneg hp hq]
    · rw [heq]
    · have hc255 : c.val ≠ 255 := by have := a.isLt; omega
      have hstep : (c.val : ℝ) + 1 ≤ (a.val : ℝ) := by
        exact_mod_cast Nat.succ_le_of_lt hgt
      have hb := hhi hc255
      have hp : 0 ≤ (a.val : ℝ) - (c.val : ℝ) := by linarith
      have hq : 0 ≤ (a.val : ℝ) + (c.val : ℝ) - 2 * channelIndex mu := by linarith
      nlinarith only [mul_nonneg hp hq]
  unfold channelCost
  rw [index_distance_even, index_distance_even, div_pow, div_pow]
  exact div_le_div_of_nonneg_right hsq (by positivity)

theorem nearestChannelEven_minimizes (mu : ℝ) (a : Channel) :
    channelCost mu (nearestChannelEven mu) ≤ channelCost mu a := by
  let n := roundTiesEven (channelIndex mu)
  have hn := roundTiesEven_interval (channelIndex mu)
  change (n : ℝ) - 1 / 2 ≤ channelIndex mu ∧ channelIndex mu ≤ (n : ℝ) + 1 / 2 at hn
  apply channel_minimizes_of_closed_interval
  · intro hc
    change min 255 n.toNat ≠ 0 at hc
    have hn0 : 0 ≤ n := by omega
    have hcast : (n.toNat : ℝ) = (n : ℝ) := by exact_mod_cast Int.toNat_of_nonneg hn0
    change ((min 255 n.toNat : ℕ) : ℝ) - 1 / 2 ≤ channelIndex mu
    have hle : ((min 255 n.toNat : ℕ) : ℝ) ≤ (n.toNat : ℝ) := by
      exact_mod_cast Nat.min_le_right 255 n.toNat
    rw [hcast] at hle
    linarith [hn.1]
  · intro hc
    change min 255 n.toNat ≠ 255 at hc
    have hnat : min 255 n.toNat = n.toNat := by omega
    change channelIndex mu ≤ ((min 255 n.toNat : ℕ) : ℝ) + 1 / 2
    rw [hnat]
    have hle : (n : ℝ) ≤ (n.toNat : ℝ) := by exact_mod_cast Int.self_le_toNat n
    linarith [hn.2]

theorem nearestChannelEven_exact_of_margin (mu : ℝ) (c : Channel)
    (hc : |mu - channelValue c| < 1 / 256) : nearestChannelEven mu = c := by
  by_contra hne
  have gap := channelValue_abs_gap (nearestChannelEven mu) c hne
  have hcost := sq_le_sq.mp (nearestChannelEven_minimizes mu c)
  have ht := abs_add_le (channelValue (nearestChannelEven mu) - mu) (mu - channelValue c)
  rw [sub_add_sub_cancel] at ht
  rw [abs_sub_comm (channelValue c) mu] at hcost
  linarith

def nearestRGBEven (mu : EuclideanSpace ℝ (Fin 3)) : RGB :=
  fun j => nearestChannelEven (mu j)

theorem nearestRGBEven_minimizes (mu : EuclideanSpace ℝ (Fin 3)) (c : RGB) :
    ‖rgbValue (nearestRGBEven mu) - mu‖ ^ 2 ≤ ‖rgbValue c - mu‖ ^ 2 := by
  rw [rgbValue_norm_sq, rgbValue_norm_sq]
  apply Finset.sum_le_sum
  intro j _
  exact nearestChannelEven_minimizes (mu j) (c j)

theorem nearestRGBEven_exact_of_margin (mu : EuclideanSpace ℝ (Fin 3)) (c : RGB)
    (hc : ∀ j, |mu j - channelValue (c j)| < 1 / 256) : nearestRGBEven mu = c := by
  funext j
  exact nearestChannelEven_exact_of_margin (mu j) (c j) (hc j)

end TypeEmbeddings
