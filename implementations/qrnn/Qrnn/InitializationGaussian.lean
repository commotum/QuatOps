import Qrnn.InitializationMoments
import Mathlib.Probability.Distributions.Gaussian.Real
import Mathlib.Probability.HasLaw

/-!
# Gaussian quaternion component laws

Each real component has law N(0,v). Independence would additionally identify the
norm's chi law, but is not needed for the proved norm second moment or covariance
trace. No density or norm-variance assertion is inferred from this result.
-/

namespace Qrnn
open MeasureTheory ProbabilityTheory
open scoped NNReal
noncomputable section

private theorem gaussian_square_integral (v : ℝ≥0) :
    (∫ x : ℝ, x ^ 2 ∂gaussianReal 0 v) = v := by
  have hm : (∫ x : ℝ, x ∂gaussianReal 0 v) = 0 := integral_id_gaussianReal
  exact (variance_of_integral_eq_zero (X := fun x : ℝ => x)
    measurable_id.aemeasurable hm).symm.trans variance_fun_id_gaussianReal

/-- The actual Gaussian component law provides its finite second moment. -/
theorem gaussianComponent_memLp {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (X : Ω → ℝ) (v : ℝ≥0) (h : HasLaw X (gaussianReal 0 v) μ) :
    MemLp X 2 μ := by
  have hv := memLp_id_gaussianReal' (μ := 0) (v := v) 2 (by norm_num)
  have hvmap : MemLp id 2 (μ.map X) := h.map_eq.symm ▸ hv
  simpa only [Function.id_comp] using hvmap.comp_of_map h.aemeasurable

/-- Gaussian marginals with variance v give quaternion norm second moment 4v. -/
theorem gaussianQuaternion_secondMoment {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (W : Ω → Q) (v : ℝ≥0)
    (h : ∀ a : Fin 4, HasLaw (fun ω => components (W ω) a) (gaussianReal 0 v) μ) :
    quaternionSecondMoment μ W = 4 * (v : ℝ) := by
  apply quaternionSecondMoment_four μ W v
  · intro a
    exact (gaussianComponent_memLp μ _ v (h a)).integrable_sq
  · intro a
    have he := (h a).integral_comp (f := fun x : ℝ => x ^ 2) (by fun_prop)
    exact he.trans (gaussian_square_integral v)

/-- Centered Gaussian components give covariance trace 4v, which is not norm variance. -/
theorem gaussianQuaternion_variance {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (W : Ω → Q) (v : ℝ≥0)
    (h : ∀ a : Fin 4, HasLaw (fun ω => components (W ω) a) (gaussianReal 0 v) μ) :
    quaternionVariance μ W = 4 * (v : ℝ) := by
  rw [quaternionVariance_of_centered μ W
    (fun a => gaussianComponent_memLp μ _ v (h a))]
  · exact gaussianQuaternion_secondMoment μ W v h
  · intro a
    exact (h a).integral_eq.trans integral_id_gaussianReal

/-- The appendix's 4σ² conclusion is valid as a norm second moment for this model. -/
theorem gaussianQuaternion_sigma_secondMoment {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (W : Ω → Q) (σ : ℝ)
    (h : ∀ a : Fin 4, HasLaw (fun ω => components (W ω) a)
      (gaussianReal 0 ⟨σ ^ 2, sq_nonneg σ⟩) μ) :
    quaternionSecondMoment μ W = 4 * σ ^ 2 :=
  gaussianQuaternion_secondMoment μ W ⟨σ ^ 2, sq_nonneg σ⟩ h

end
end Qrnn
