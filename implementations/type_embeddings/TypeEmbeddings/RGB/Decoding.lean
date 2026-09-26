import TypeEmbeddings.RGB.Nearest
import TypeEmbeddings.Bank.LeastSquares

/-! Global least-squares RGB decoding and exact arithmetic recovery margins. -/

noncomputable section
namespace TypeEmbeddings

/-- The tied reader followed by independent exact nearest-grid selection. -/
def decodeRGB {N : ℕ} (w : Fin N → Quaternion ℝ) (h : BankSpace N) : RGB :=
  nearestRGB (analyticDecoder w h)

/-- Channelwise rounding solves the global RGB reconstruction minimization problem. -/
theorem nearestRGB_global_minimizer {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (h : BankSpace N) (c : RGB) :
    ‖h - encoder w (rgbValue (decodeRGB w h))‖ ^ 2 ≤ ‖h - encoder w (rgbValue c)‖ ^ 2 := by
  rw [reconstruction_score w hS, reconstruction_score w hS]
  exact add_le_add_left
    (mul_le_mul_of_nonneg_left (nearestRGB_minimizes (analyticDecoder w h) c) hS.le) _

/-- The per-coordinate strict margin is the infinity-norm condition without a norm ambiguity. -/
theorem decodeRGB_exact_of_margin {N : ℕ} (w : Fin N → Quaternion ℝ)
    (h : BankSpace N) (c : RGB)
    (hc : ∀ j, |analyticDecoder w h j - channelValue (c j)| < 1 / 256) : decodeRGB w h = c :=
  nearestRGB_exact_of_margin _ c hc

theorem decodeRGB_roundTrip {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (c : RGB) : decodeRGB w (encoder w (rgbValue c)) = c := by
  apply decodeRGB_exact_of_margin
  intro j
  rw [decoder_roundTrip w hS]
  simp [rgbValue]

/-- A sufficient Euclidean hidden-state perturbation bound for exact RGB recovery. -/
theorem decodeRGB_exact_of_noise {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (c : RGB) (e : BankSpace N)
    (he : ‖e‖ < Real.sqrt (bankEnergy w) / 256) : decodeRGB w (encoder w (rgbValue c) + e) = c := by
  apply decodeRGB_exact_of_margin
  intro j
  have hcoord := PiLp.norm_apply_le (analyticDecoder w (encoder w (rgbValue c) + e) - rgbValue c) j
  have hbound := decoder_error_bound w hS (rgbValue c) e
  have hs : 0 < Real.sqrt (bankEnergy w) := Real.sqrt_pos.mpr hS
  have hsmall : ‖e‖ / Real.sqrt (bankEnergy w) < 1 / 256 := by
    apply (div_lt_iff₀ hs).mpr
    simpa [div_eq_mul_inv, mul_comm] using he
  have hc := lt_of_le_of_lt (hcoord.trans hbound) hsmall
  simpa [Real.norm_eq_abs, rgbValue] using hc

end TypeEmbeddings
