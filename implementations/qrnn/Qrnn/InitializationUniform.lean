import Qrnn.InitializationMoments
import Mathlib.Probability.ConditionalProbability
import Mathlib.Probability.HasLaw
import Mathlib.Probability.Independence.Integration
import Mathlib.Analysis.SpecialFunctions.Integrals.Basic

/-!
# Moments of the paper's bounded uniform polar amplitude

The law is normalized Lebesgue measure on (-σ,σ]. Endpoints have zero Lebesgue
measure, so this implements the continuous uniform sampling interval [-σ,σ].
The nondegenerate model requires σ > 0; a zero scale would use a Dirac law instead.
-/

namespace Qrnn
open MeasureTheory ProbabilityTheory
noncomputable section

/-- Continuous signed uniform amplitude with positive width supplied by theorem hypotheses. -/
def uniformAmplitudeLaw (σ : ℝ) : Measure ℝ := ProbabilityTheory.cond volume (Set.Ioc (-σ) σ)

theorem uniformAmplitudeLaw_isProbability (σ : ℝ) (hσ : 0 < σ) :
    IsProbabilityMeasure (uniformAmplitudeLaw σ) := by
  apply cond_isProbabilityMeasure_of_finite
  · rw [Real.volume_Ioc]
    exact (ENNReal.ofReal_pos.mpr (by linarith)).ne'
  · rw [Real.volume_Ioc]
    exact ENNReal.ofReal_ne_top

/-- The signed uniform amplitude is centered. -/
theorem uniformAmplitude_mean (σ : ℝ) (hσ : 0 < σ) :
    (∫ x : ℝ, x ∂uniformAmplitudeLaw σ) = 0 := by
  rw [uniformAmplitudeLaw, ProbabilityTheory.cond, integral_smul_measure,
    ← intervalIntegral.integral_of_le (by linarith : -σ ≤ σ), integral_id]
  ring

/-- Its second moment is σ²/3, not the Gaussian four-component moment 4σ². -/
theorem uniformAmplitude_secondMoment (σ : ℝ) (hσ : 0 < σ) :
    (∫ x : ℝ, x ^ 2 ∂uniformAmplitudeLaw σ) = σ ^ 2 / 3 := by
  rw [uniformAmplitudeLaw, ProbabilityTheory.cond, integral_smul_measure, Real.volume_Ioc,
    ENNReal.toReal_inv, ENNReal.toReal_ofReal (by linarith : 0 ≤ σ - -σ),
    ← intervalIntegral.integral_of_le (by linarith : -σ ≤ σ), integral_pow]
  rw [show σ - -σ = 2 * σ by ring]
  field_simp [ne_of_gt hσ]
  ring_nf
  field_simp [ne_of_gt hσ]


private theorem abs_interval_integral (σ : ℝ) (hσ : 0 < σ) :
    (∫ x : ℝ in -σ..σ, |x|) = σ ^ 2 := by
  have hl : (∫ x : ℝ in -σ..0, |x|) = σ ^ 2 / 2 := by
    have he : (∫ x : ℝ in -σ..0, |x|) = ∫ x : ℝ in -σ..0, -x := by
      apply intervalIntegral.integral_congr
      intro x hx
      rw [Set.uIcc_of_le (by linarith : -σ ≤ 0)] at hx
      exact abs_of_nonpos hx.2
    rw [he, intervalIntegral.integral_neg, integral_id]
    ring
  have hr : (∫ x : ℝ in 0..σ, |x|) = σ ^ 2 / 2 := by
    have he : (∫ x : ℝ in 0..σ, |x|) = ∫ x : ℝ in 0..σ, x := by
      apply intervalIntegral.integral_congr
      intro x hx
      rw [Set.uIcc_of_le hσ.le] at hx
      exact abs_of_nonneg hx.1
    rw [he, integral_id]
    ring
  rw [← intervalIntegral.integral_add_adjacent_intervals
    (continuous_abs.intervalIntegrable (-σ) 0) (continuous_abs.intervalIntegrable 0 σ), hl, hr]
  ring

/-- A uniform signed amplitude has mean absolute value σ/2. -/
theorem uniformAmplitude_abs_mean (σ : ℝ) (hσ : 0 < σ) :
    (∫ x : ℝ, |x| ∂uniformAmplitudeLaw σ) = σ / 2 := by
  rw [uniformAmplitudeLaw, ProbabilityTheory.cond, integral_smul_measure, Real.volume_Ioc,
    ENNReal.toReal_inv, ENNReal.toReal_ofReal (by linarith : 0 ≤ σ - -σ),
    ← intervalIntegral.integral_of_le (by linarith : -σ ≤ σ), abs_interval_integral σ hσ]
  rw [show σ - -σ = 2 * σ by ring]
  field_simp [ne_of_gt hσ]
  ring_nf
  field_simp [ne_of_gt hσ]

/-- The amplitude law entails finite real second moments, not just a formal integral value. -/
theorem uniformAmplitude_memLp {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    (X : Ω → ℝ) (σ : ℝ) (hσ : 0 < σ) (h : HasLaw X (uniformAmplitudeLaw σ) μ) :
    MemLp X 2 μ := by
  letI := uniformAmplitudeLaw_isProbability σ hσ
  have hb : ∀ᵐ x ∂uniformAmplitudeLaw σ, ‖id x‖ ≤ σ := by
    apply ae_cond_of_forall_mem measurableSet_Ioc
    intro x hx
    exact abs_le.mpr ⟨hx.1.le, hx.2⟩
  have hv : MemLp id 2 (uniformAmplitudeLaw σ) := MemLp.of_bound aestronglyMeasurable_id σ hb
  have hm : MemLp id 2 (μ.map X) := h.map_eq.symm ▸ hv
  simpa only [Function.id_comp] using hm.comp_of_map h.aemeasurable

/-- One continuously uniform positive direction coordinate suffices to exclude
zero normalization almost surely. Independence of the other coordinates is not needed. -/
theorem imaginarySample_nonzero_ae {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    (v : Ω → Fin 3 → ℝ)
    (hv : HasLaw (fun ω => v ω 0) (ProbabilityTheory.cond volume (Set.Ioc (0 : ℝ) 1)) μ) :
    ∀ᵐ ω ∂μ, imaginarySample (v ω) ≠ 0 := by
  have hb : ∀ᵐ x ∂ProbabilityTheory.cond volume (Set.Ioc (0 : ℝ) 1), x ≠ 0 :=
    ae_cond_of_forall_mem measurableSet_Ioc (fun x hx => ne_of_gt hx.1)
  have hx : ∀ᵐ ω ∂μ, v ω 0 ≠ 0 := (hv.ae_iff (by fun_prop)).mpr hb
  filter_upwards [hx] with ω hω
  intro hz
  apply hω
  exact congrArg QuaternionAlgebra.imI hz

/-- The actual signed uniform amplitude law gives the polar sampler norm moment. -/
theorem uniformPolar_secondMoment {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (amplitude angle : Ω → ℝ) (direction : Ω → Q) (σ : ℝ) (hσ : 0 < σ)
    (ha : HasLaw amplitude (uniformAmplitudeLaw σ) μ)
    (hr : ∀ᵐ ω ∂μ, (direction ω).re = 0) (hn : ∀ᵐ ω ∂μ, ‖direction ω‖ = 1) :
    quaternionSecondMoment μ (fun ω => polarWeight (amplitude ω) (angle ω) (direction ω)) =
      σ ^ 2 / 3 := by
  rw [polar_secondMoment μ amplitude angle direction hr hn]
  have he := ha.integral_comp (f := fun x : ℝ => x ^ 2) (by fun_prop)
  exact he.trans (uniformAmplitude_secondMoment σ hσ)


/-- The polar sampler's norm has positive mean σ/2 regardless of its angle/direction laws. -/
theorem uniformPolar_norm_mean {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (amplitude angle : Ω → ℝ) (direction : Ω → Q) (σ : ℝ) (hσ : 0 < σ)
    (ha : HasLaw amplitude (uniformAmplitudeLaw σ) μ)
    (hr : ∀ᵐ ω ∂μ, (direction ω).re = 0) (hn : ∀ᵐ ω ∂μ, ‖direction ω‖ = 1) :
    (∫ ω, ‖polarWeight (amplitude ω) (angle ω) (direction ω)‖ ∂μ) = σ / 2 := by
  have he : (∫ ω, ‖polarWeight (amplitude ω) (angle ω) (direction ω)‖ ∂μ) =
      ∫ ω, |amplitude ω| ∂μ := by
    apply integral_congr_ae
    filter_upwards [hr, hn] with ω hreal hnorm
    exact polar_norm _ _ _ hreal hnorm
  rw [he]
  exact (ha.integral_comp (f := fun x : ℝ => |x|) (by fun_prop)).trans
    (uniformAmplitude_abs_mean σ hσ)

/-- The actual bounded polar norm variance is σ²/12; it is neither σ²/3 nor 4σ². -/
theorem uniformPolar_norm_variance {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (amplitude angle : Ω → ℝ) (direction : Ω → Q) (σ : ℝ) (hσ : 0 < σ)
    (ha : HasLaw amplitude (uniformAmplitudeLaw σ) μ)
    (hr : ∀ᵐ ω ∂μ, (direction ω).re = 0) (hn : ∀ᵐ ω ∂μ, ‖direction ω‖ = 1) :
    variance (fun ω => ‖polarWeight (amplitude ω) (angle ω) (direction ω)‖) μ = σ ^ 2 / 12 := by
  have he : (fun ω => ‖amplitude ω‖) =ᵐ[μ]
      (fun ω => ‖polarWeight (amplitude ω) (angle ω) (direction ω)‖) := by
    filter_upwards [hr, hn] with ω hreal hnorm
    exact (polar_norm _ _ _ hreal hnorm).symm
  have hL := ((uniformAmplitude_memLp μ amplitude σ hσ ha).norm).ae_eq he
  rw [variance_eq_sub hL]
  change quaternionSecondMoment μ (fun ω => polarWeight (amplitude ω) (angle ω) (direction ω)) -
    (∫ ω, ‖polarWeight (amplitude ω) (angle ω) (direction ω)‖ ∂μ) ^ 2 = _
  rw [uniformPolar_secondMoment μ amplitude angle direction σ hσ ha hr hn,
    uniformPolar_norm_mean μ amplitude angle direction σ hσ ha hr hn]
  ring


private theorem component_abs_le_norm (q : Q) (a : Fin 4) : |components q a| ≤ ‖q‖ := by
  have hs : components q a ^ 2 ≤ ∑ b : Fin 4, components q b ^ 2 :=
    Finset.single_le_sum (fun b _ => sq_nonneg (components q b)) (Finset.mem_univ a)
  rw [← norm_sq_components] at hs
  nlinarith [sq_abs (components q a), abs_nonneg (components q a), norm_nonneg q]

private theorem polar_component_amplitude (amplitude angle : ℝ) (direction : Q) (a : Fin 4) :
    components (polarWeight amplitude angle direction) a =
      amplitude * components (polarWeight 1 angle direction) a := by
  fin_cases a <;> simp [polarWeight, components, Quaternion.equivTuple_apply] <;> ring

private theorem uniformAmplitude_bound {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (amplitude : Ω → ℝ) (σ : ℝ)
    (ha : HasLaw amplitude (uniformAmplitudeLaw σ) μ) :
    ∀ᵐ ω ∂μ, |amplitude ω| ≤ σ := by
  apply (ha.ae_iff (p := fun x : ℝ => |x| ≤ σ) (by fun_prop)).mpr
  exact ae_cond_of_forall_mem measurableSet_Ioc (fun x hx => abs_le.mpr ⟨hx.1.le, hx.2⟩)

/-- With amplitude independent of every angular/directional factor, the bounded
polar quaternion is centered and its covariance trace is σ²/3. This independence
hypothesis is additional to the norm-moment result and must not be omitted. -/
theorem uniformPolar_quaternionVariance {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (amplitude angle : Ω → ℝ) (direction : Ω → Q) (σ : ℝ) (hσ : 0 < σ)
    (ha : HasLaw amplitude (uniformAmplitudeLaw σ) μ)
    (hr : ∀ᵐ ω ∂μ, (direction ω).re = 0) (hn : ∀ᵐ ω ∂μ, ‖direction ω‖ = 1)
    (hfactor : ∀ a : Fin 4, AEStronglyMeasurable
      (fun ω => components (polarWeight 1 (angle ω) (direction ω)) a) μ)
    (hindep : ∀ a : Fin 4, IndepFun amplitude
      (fun ω => components (polarWeight 1 (angle ω) (direction ω)) a) μ) :
    quaternionVariance μ (fun ω => polarWeight (amplitude ω) (angle ω) (direction ω)) =
      σ ^ 2 / 3 := by
  have he (a : Fin 4) : (fun ω => components (polarWeight (amplitude ω) (angle ω) (direction ω)) a) =
      (fun ω => amplitude ω * components (polarWeight 1 (angle ω) (direction ω)) a) :=
    funext (fun ω => polar_component_amplitude _ _ _ a)
  have hL (a : Fin 4) : MemLp
      (fun ω => components (polarWeight (amplitude ω) (angle ω) (direction ω)) a) 2 μ := by
    have hm : AEStronglyMeasurable
        (fun ω => components (polarWeight (amplitude ω) (angle ω) (direction ω)) a) μ := by
      rw [he a]
      exact ha.aemeasurable.aestronglyMeasurable.mul (hfactor a)
    apply MemLp.of_bound hm σ
    filter_upwards [uniformAmplitude_bound μ amplitude σ ha, hr, hn] with ω hω hreal hnorm
    rw [Real.norm_eq_abs]
    exact (component_abs_le_norm _ a).trans
      ((polar_norm _ _ _ hreal hnorm).le.trans hω)
  have hc (a : Fin 4) :
      (∫ ω, components (polarWeight (amplitude ω) (angle ω) (direction ω)) a ∂μ) = 0 := by
    rw [he a, (hindep a).integral_fun_mul_eq_mul_integral
      ha.aemeasurable.aestronglyMeasurable (hfactor a)]
    have hm : (∫ ω, amplitude ω ∂μ) = 0 := ha.integral_eq.trans (uniformAmplitude_mean σ hσ)
    rw [hm, zero_mul]
  rw [quaternionVariance_of_centered μ _ hL hc]
  exact uniformPolar_secondMoment μ amplitude angle direction σ hσ ha hr hn

/-- At positive scale the actual bounded polar moment differs from the paper's Gaussian claim. -/
theorem uniformPolar_moment_ne_gaussian (σ : ℝ) (hσ : 0 < σ) :
    σ ^ 2 / 3 ≠ 4 * σ ^ 2 := by nlinarith [sq_pos_of_pos hσ]

/-- The printed σ scale gives 1/(6 fan) for this sampler, rather than 2/fan. -/
theorem uniformPolar_paperScale_secondMoment (fan : ℝ) (hfan : 0 < fan) :
    gaussianScale fan ^ 2 / 3 = 1 / (6 * fan) := by
  have hs := gaussianScale_secondMoment fan hfan
  have hn : fan ≠ 0 := ne_of_gt hfan
  field_simp at hs ⊢
  nlinarith

/-- The repaired bounded-amplitude sampler attains a prescribed positive norm second moment. -/
theorem correctedUniformPolar_secondMoment {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (amplitude angle : Ω → ℝ) (direction : Ω → Q)
    (target : ℝ) (ht : 0 < target)
    (ha : HasLaw amplitude (uniformAmplitudeLaw (uniformAmplitudeBound target)) μ)
    (hr : ∀ᵐ ω ∂μ, (direction ω).re = 0) (hn : ∀ᵐ ω ∂μ, ‖direction ω‖ = 1) :
    quaternionSecondMoment μ (fun ω => polarWeight (amplitude ω) (angle ω) (direction ω)) = target := by
  have hb : 0 < uniformAmplitudeBound target := Real.sqrt_pos.mpr (by positivity)
  rw [uniformPolar_secondMoment μ amplitude angle direction (uniformAmplitudeBound target) hb ha hr hn]
  exact uniformAmplitudeBound_secondMoment target ht.le

end
end Qrnn
