import TypeEmbeddings.RGB.Core
import Mathlib.Data.Rat.Cast.Order

/-! Exact representability in the ideal finite normal BF16 value set. This does not
model operation rounding, accumulation, NaNs, or hardware execution. -/

namespace TypeEmbeddings

/-- A normal BF16 real value has an eight-bit normalized signed significand, with
7 fraction bits, and unbiased IEEE-style normal exponent in [-126,127]. The integer
mantissa absorbs the factor 2⁻⁷, so its exponent range is [-133,120]. -/
def IsNormalBF16 (x : ℝ) : Prop := ∃ m e : ℤ,
  128 ≤ m.natAbs ∧ m.natAbs ≤ 255 ∧ -133 ≤ e ∧ e ≤ 120 ∧ x = (m : ℝ) * (2 : ℝ) ^ e

private def channelNumerator (c : Channel) : ℤ := 2 * (c.val : ℤ) - 255
private def normalizationShift (c : Channel) : ℕ :=
  let a := (channelNumerator c).natAbs
  if a < 2 then 7 else if a < 4 then 6 else if a < 8 then 5 else
  if a < 16 then 4 else if a < 32 then 3 else if a < 64 then 2 else
  if a < 128 then 1 else 0
private def channelMantissa (c : Channel) : ℤ := channelNumerator c * 2 ^ normalizationShift c
private def channelExponent (c : Channel) : ℤ := -8 - (normalizationShift c : ℤ)
private def channelRational (c : Channel) : ℚ := (2 * (c.val : ℚ) - 255) / 256

/-- A finite, kernel-checked exact rational certificate covering every byte value. -/
private theorem channelCertificate : ∀ c : Channel,
    128 ≤ (channelMantissa c).natAbs ∧ (channelMantissa c).natAbs ≤ 255 ∧
    -133 ≤ channelExponent c ∧ channelExponent c ≤ 120 ∧
    channelRational c = (channelMantissa c : ℚ) * (2 : ℚ) ^ channelExponent c := by
  decide +kernel

/-- Every exact RGB channel value is a normal BF16 value, without arithmetic rounding. -/
theorem channelValue_bf16 (c : Channel) : IsNormalBF16 (channelValue c) := by
  obtain ⟨hm0, hm1, he0, he1, hq⟩ := channelCertificate c
  refine ⟨channelMantissa c, channelExponent c, hm0, hm1, he0, he1, ?_⟩
  have hr := congrArg (fun q : ℚ => (q : ℝ)) hq
  simpa [channelRational, channelValue] using hr

/-- The grid values are dyadic rationals independently of any floating-point format. -/
theorem channelValue_dyadic (c : Channel) :
    channelValue c = (channelNumerator c : ℝ) / (2 : ℝ) ^ (8 : ℕ) := by
  norm_num [channelValue, channelNumerator]

/-- Ideal normal BF16 storage rounding: use the input binade, round to the nearest
8-bit significand, and choose an even significand on a half-way tie. No operation
accumulation behavior is specified by this relation. -/
def RoundsNormalBF16 (x y : ℝ) : Prop := ∃ m e : ℤ,
  128 ≤ m.natAbs ∧ m.natAbs ≤ 255 ∧ -133 ≤ e ∧ e ≤ 120 ∧
  y = (m : ℝ) * (2 : ℝ) ^ e ∧
  128 ≤ |x / (2 : ℝ) ^ e| ∧ |x / (2 : ℝ) ^ e| < 256 ∧
  |x / (2 : ℝ) ^ e - (m : ℝ)| ≤ 1 / 2 ∧
  (|x / (2 : ℝ) ^ e - (m : ℝ)| = 1 / 2 → Even m)

end TypeEmbeddings
