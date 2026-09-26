import TypeEmbeddings.Bank.LeastSquares

/-! A residual-derived kernel variance. Positivity is mathematical; calibration is not. -/

noncomputable section
namespace TypeEmbeddings

/-- Fixed positive floor and positive bank-level gain. -/
structure WidthParameters where
  floor : ℝ
  floor_pos : 0 < floor
  gain : ℝ
  gain_pos : 0 < gain

def residualDegrees (N : ℕ) : ℝ := 4 * (N : ℝ) - 3

theorem residualDegrees_pos {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) : 0 < residualDegrees N := by
  obtain ⟨i, _⟩ := (bankEnergy_pos_iff w).mp hS
  have hN : 1 ≤ N := by have := i.isLt; omega
  have hNr : (1 : ℝ) ≤ (N : ℝ) := by exact_mod_cast hN
  unfold residualDegrees
  linarith

def residualEnergy {N : ℕ} (w : Fin N → Quaternion ℝ) (h : BankSpace N) : ℝ :=
  ‖residual w h‖ ^ 2

theorem residualEnergy_nonneg {N : ℕ} (w : Fin N → Quaternion ℝ) (h : BankSpace N) :
    0 ≤ residualEnergy w h := sq_nonneg _

def residualVariance {N : ℕ} (w : Fin N → Quaternion ℝ)
    (p : WidthParameters) (h : BankSpace N) : ℝ :=
  p.floor ^ 2 + p.gain * (residualEnergy w h / (bankEnergy w * residualDegrees N))

theorem residualVariance_floor {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (p : WidthParameters) (h : BankSpace N) :
    p.floor ^ 2 ≤ residualVariance w p h := by
  exact le_add_of_nonneg_right (mul_nonneg p.gain_pos.le
    (div_nonneg (residualEnergy_nonneg w h) (mul_pos hS (residualDegrees_pos w hS)).le))

theorem residualVariance_pos {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (p : WidthParameters) (h : BankSpace N) :
    0 < residualVariance w p h :=
  (sq_pos_of_pos p.floor_pos).trans_le (residualVariance_floor w hS p h)

/-- Only residual energy varies: the bank, floor and gain stay fixed. -/
theorem residualVariance_mono {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (p : WidthParameters) (h k : BankSpace N)
    (hk : residualEnergy w h ≤ residualEnergy w k) :
    residualVariance w p h ≤ residualVariance w p k := by
  exact add_le_add (le_refl _) (mul_le_mul_of_nonneg_left
    (div_le_div_of_nonneg_right hk (mul_pos hS (residualDegrees_pos w hS)).le) p.gain_pos.le)

theorem residualVariance_strict_mono {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (p : WidthParameters) (h k : BankSpace N)
    (hk : residualEnergy w h < residualEnergy w k) :
    residualVariance w p h < residualVariance w p k := by
  have hh := mul_lt_mul_of_pos_left
    ((div_lt_div_iff_of_pos_right (mul_pos hS (residualDegrees_pos w hS))).mpr hk)
    p.gain_pos
  unfold residualVariance
  linarith only [hh]

theorem residualVariance_eq_floor_iff {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (p : WidthParameters) (h : BankSpace N) :
    residualVariance w p h = p.floor ^ 2 ↔ residual w h = 0 := by
  constructor
  · intro he
    have hz : p.gain * (residualEnergy w h / (bankEnergy w * residualDegrees N)) = 0 := by
      unfold residualVariance at he
      linarith only [he]
    have hd := (mul_eq_zero.mp hz).resolve_left (ne_of_gt p.gain_pos)
    have hr := (div_eq_zero_iff.mp hd).resolve_right
      (ne_of_gt (mul_pos hS (residualDegrees_pos w hS)))
    exact norm_eq_zero.mp (sq_eq_zero_iff.mp hr)
  · intro hr
    simp only [residualVariance, residualEnergy, hr, norm_zero,
      zero_pow (by decide : 2 ≠ 0), zero_div, mul_zero, add_zero]

theorem residualVariance_at_code {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (p : WidthParameters) (x : RGBSpace) :
    residualVariance w p (encoder w x) = p.floor ^ 2 := by
  simp only [residualVariance, residualEnergy, residual, decoder_roundTrip w hS,
    sub_self, norm_zero, zero_pow (by decide : 2 ≠ 0), zero_div, mul_zero, add_zero]

def residualScale {N : ℕ} (w : Fin N → Quaternion ℝ)
    (p : WidthParameters) (h : BankSpace N) : ℝ := Real.sqrt (residualVariance w p h)

theorem residualScale_pos {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (p : WidthParameters) (h : BankSpace N) :
    0 < residualScale w p h := Real.sqrt_pos.mpr (residualVariance_pos w hS p h)

theorem residualScale_sq {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (p : WidthParameters) (h : BankSpace N) :
    residualScale w p h ^ 2 = residualVariance w p h :=
  Real.sq_sqrt (residualVariance_pos w hS p h).le

end TypeEmbeddings
