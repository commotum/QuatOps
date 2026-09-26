import Qrnn.Algebra
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic

/-!
# Polar quaternion initialization algebra

The amplitude is signed. Its absolute value is the norm when the direction is
purely imaginary and has unit norm. Probability models are separate.
-/

namespace Qrnn
noncomputable section

/-- The four-component polar formula printed by the paper. -/
def polarWeight (amplitude angle : ℝ) (direction : Q) : Q :=
  ⟨amplitude * Real.cos angle,
    amplitude * direction.imI * Real.sin angle,
    amplitude * direction.imJ * Real.sin angle,
    amplitude * direction.imK * Real.sin angle⟩

/-- A pure imaginary sample before normalization. -/
def imaginarySample (v : Fin 3 → ℝ) : Q := ⟨0, v 0, v 1, v 2⟩

/-- The algorithm's normalized direction, with mathlib's total zero fallback. -/
def sampledDirection (v : Fin 3 → ℝ) : Q := normalize (imaginarySample v)

@[simp] theorem sampledDirection_re (v : Fin 3 → ℝ) : (sampledDirection v).re = 0 := by
  simp [sampledDirection, normalize, imaginarySample, Quaternion.re_smul]

theorem sampledDirection_norm (v : Fin 3 → ℝ) (hv : imaginarySample v ≠ 0) :
    ‖sampledDirection v‖ = 1 := normalize_norm _ hv

/-- The nonzero direction hypothesis is needed to preserve the polar norm. -/
theorem polar_norm_sq (amplitude angle : ℝ) (direction : Q)
    (hreal : direction.re = 0) (hnorm : ‖direction‖ = 1) :
    ‖polarWeight amplitude angle direction‖ ^ 2 = amplitude ^ 2 := by
  have hu : direction.imI ^ 2 + direction.imJ ^ 2 + direction.imK ^ 2 = 1 := by
    have h := Quaternion.normSq_eq_norm_mul_self direction
    rw [Quaternion.normSq_def', hreal, hnorm] at h
    simpa using h
  rw [pow_two, ← Quaternion.normSq_eq_norm_mul_self, Quaternion.normSq_def']
  change (amplitude * Real.cos angle) ^ 2 +
    (amplitude * direction.imI * Real.sin angle) ^ 2 +
    (amplitude * direction.imJ * Real.sin angle) ^ 2 +
    (amplitude * direction.imK * Real.sin angle) ^ 2 = amplitude ^ 2
  calc
    _ = amplitude ^ 2 * (Real.cos angle ^ 2 +
      (direction.imI ^ 2 + direction.imJ ^ 2 + direction.imK ^ 2) * Real.sin angle ^ 2) := by ring
    _ = amplitude ^ 2 := by rw [hu, one_mul, Real.cos_sq_add_sin_sq, mul_one]

theorem polar_norm (amplitude angle : ℝ) (direction : Q)
    (hreal : direction.re = 0) (hnorm : ‖direction‖ = 1) :
    ‖polarWeight amplitude angle direction‖ = |amplitude| := by
  have h := polar_norm_sq amplitude angle direction hreal hnorm
  nlinarith [norm_nonneg (polarWeight amplitude angle direction), abs_nonneg amplitude,
    sq_abs amplitude]

/-- Polar sampling from a nonzero imaginary sample preserves squared amplitude. -/
theorem sampled_polar_norm_sq (amplitude angle : ℝ) (v : Fin 3 → ℝ)
    (hv : imaginarySample v ≠ 0) :
    ‖polarWeight amplitude angle (sampledDirection v)‖ ^ 2 = amplitude ^ 2 :=
  polar_norm_sq _ _ _ (sampledDirection_re v) (sampledDirection_norm v hv)

/-- The paper's proposed Gaussian component scale for a positive real fan sum. -/
def gaussianScale (fan : ℝ) : ℝ := (Real.sqrt (2 * fan))⁻¹

/-- Gaussian component moments give the intended Glorot/He target with this scale. -/
theorem gaussianScale_secondMoment (fan : ℝ) (hfan : 0 < fan) :
    4 * gaussianScale fan ^ 2 = 2 / fan := by
  have hf : 0 < 2 * fan := by positivity
  simp only [gaussianScale, inv_pow, Real.sq_sqrt hf.le]
  field_simp
  ring

/-- Correct uniform signed-amplitude bound for a prescribed nonnegative norm second moment. -/
def uniformAmplitudeBound (target : ℝ) : ℝ := Real.sqrt (3 * target)

theorem uniformAmplitudeBound_secondMoment (target : ℝ) (ht : 0 ≤ target) :
    uniformAmplitudeBound target ^ 2 / 3 = target := by
  rw [uniformAmplitudeBound, Real.sq_sqrt (by positivity)]
  ring

end
end Qrnn
