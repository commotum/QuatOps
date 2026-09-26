import Qrnn.InitializationCore
import Mathlib.Probability.Moments.Variance

/-!
# Quaternion component moments and the variance of the norm

The trace of the real covariance matrix is the sum of the four component
variances. It is distinct from the scalar variance of the nonnegative norm.
-/

namespace Qrnn
open MeasureTheory ProbabilityTheory
noncomputable section

/-- Second moment of a quaternion's Euclidean norm. -/
def quaternionSecondMoment {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) (W : Ω → Q) : ℝ :=
  ∫ ω, ‖W ω‖ ^ 2 ∂μ

/-- Sum of real component variances (trace of covariance), not variance of the norm. -/
def quaternionVariance {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) (W : Ω → Q) : ℝ :=
  ∑ a : Fin 4, variance (fun ω => components (W ω) a) μ

/-- Euclidean norm-square is exactly the sum of four component squares. -/
theorem norm_sq_components (q : Q) : ‖q‖ ^ 2 = ∑ a : Fin 4, components q a ^ 2 := by
  rw [pow_two, ← Quaternion.normSq_eq_norm_mul_self]
  simp only [Quaternion.normSq_def', Fin.sum_univ_four, components, Quaternion.equivTuple_apply]
  rfl

/-- Integrable component second moments suffice; component independence is not needed. -/
theorem quaternionSecondMoment_components {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (W : Ω → Q)
    (hi : ∀ a : Fin 4, Integrable (fun ω => components (W ω) a ^ 2) μ) :
    quaternionSecondMoment μ W = ∑ a : Fin 4, ∫ ω, components (W ω) a ^ 2 ∂μ := by
  simp only [quaternionSecondMoment, norm_sq_components]
  exact integral_finsetSum _ (fun a _ => hi a)

/-- Correct centered-vector variance identity under finite real component second moments. -/
theorem quaternionVariance_eq {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (W : Ω → Q)
    (hL : ∀ a : Fin 4, MemLp (fun ω => components (W ω) a) 2 μ) :
    quaternionVariance μ W = quaternionSecondMoment μ W -
      ∑ a : Fin 4, (∫ ω, components (W ω) a ∂μ) ^ 2 := by
  rw [quaternionSecondMoment_components μ W (fun a => (hL a).integrable_sq)]
  simp only [quaternionVariance, variance_eq_sub (hL _), Finset.sum_sub_distrib, Pi.pow_apply]

/-- Centering the components, rather than the norm, gives variance = norm second moment. -/
theorem quaternionVariance_of_centered {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (W : Ω → Q)
    (hL : ∀ a : Fin 4, MemLp (fun ω => components (W ω) a) 2 μ)
    (hc : ∀ a : Fin 4, ∫ ω, components (W ω) a ∂μ = 0) :
    quaternionVariance μ W = quaternionSecondMoment μ W := by
  rw [quaternionVariance_eq μ W hL]
  simp only [hc, zero_pow (by decide : 2 ≠ 0), Finset.sum_const_zero, sub_zero]

/-- Equal component second moments give the appendix's 4σ² result, without a chi density. -/
theorem quaternionSecondMoment_four {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (W : Ω → Q) (v : ℝ)
    (hi : ∀ a : Fin 4, Integrable (fun ω => components (W ω) a ^ 2) μ)
    (hm : ∀ a : Fin 4, ∫ ω, components (W ω) a ^ 2 ∂μ = v) :
    quaternionSecondMoment μ W = 4 * v := by
  rw [quaternionSecondMoment_components μ W hi]
  simp [hm]

/-- The nonnegative norm has positive mean for any nontrivial integrable model. -/
theorem quaternionNorm_mean_pos {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (W : Ω → Q) (hi : Integrable (fun ω => ‖W ω‖) μ)
    (hnonzero : ¬∀ᵐ ω ∂μ, W ω = 0) : 0 < ∫ ω, ‖W ω‖ ∂μ := by
  have hn : 0 ≤ ∫ ω, ‖W ω‖ ∂μ := integral_nonneg (fun ω => norm_nonneg (W ω))
  have hne : (∫ ω, ‖W ω‖ ∂μ) ≠ 0 := by
    intro hz
    have ha := (integral_eq_zero_iff_of_nonneg (fun ω => norm_nonneg (W ω)) hi).mp hz
    apply hnonzero
    filter_upwards [ha] with ω hω
    exact norm_eq_zero.mp hω
  exact lt_of_le_of_ne hn (Ne.symm hne)

/-- Norm variance is strictly smaller than its second moment for a nontrivial model.
In particular symmetry around quaternion zero cannot justify a zero mean norm. -/
theorem quaternionNorm_variance_lt_secondMoment {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (W : Ω → Q)
    (hL : MemLp (fun ω => ‖W ω‖) 2 μ) (hnonzero : ¬∀ᵐ ω ∂μ, W ω = 0) :
    variance (fun ω => ‖W ω‖) μ < quaternionSecondMoment μ W := by
  have hp := quaternionNorm_mean_pos μ W (hL.integrable (by norm_num)) hnonzero
  rw [variance_eq_sub hL, quaternionSecondMoment]
  simp only [Pi.pow_apply]
  nlinarith [sq_pos_of_pos hp]

/-- The polar sampler's second moment is its signed amplitude's second moment,
regardless of dependence among amplitude, angle and direction. -/
theorem polar_secondMoment {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    (amplitude angle : Ω → ℝ) (direction : Ω → Q)
    (hreal : ∀ᵐ ω ∂μ, (direction ω).re = 0)
    (hnorm : ∀ᵐ ω ∂μ, ‖direction ω‖ = 1) :
    quaternionSecondMoment μ (fun ω => polarWeight (amplitude ω) (angle ω) (direction ω)) =
      ∫ ω, amplitude ω ^ 2 ∂μ := by
  apply integral_congr_ae
  filter_upwards [hreal, hnorm] with ω hr hn
  exact polar_norm_sq _ _ _ hr hn

end
end Qrnn
