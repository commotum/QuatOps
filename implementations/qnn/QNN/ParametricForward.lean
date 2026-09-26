import QNN.Backpropagation

/-! Differentiability with respect to simultaneous real parameter changes.

A caller can supply any real normed parameter space and differentiable coordinate
weight maps. This includes joint parameterizations, without imposing a particular
flattening or norm on the network's heterogeneous parameter record.
-/
noncomputable section
namespace QNN
open ContinuousLinearMap
section
variable {P : Type*} [NormedAddCommGroup P] [NormedSpace ℝ P] {p : P}

/-- Input and weight may depend on the same real parameter, simultaneously. -/
theorem weightAction_parametric_differentiableAt {w : P → H} {x : P → Pure}
    (hw : DifferentiableAt ℝ w p) (hx : DifferentiableAt ℝ x p) (h0 : w p ≠ 0) :
    DifferentiableAt ℝ (fun q => weightAction (w q) (x q)) p := by
  have hxH := pureSubspace.subtype.toContinuousLinearMap.differentiableAt.comp p hx
  have hn := (hw.norm ℝ h0).inv (norm_ne_zero_iff.mpr h0)
  have hd := hn.smul ((hw.mul hxH).mul hw.star)
  have hp := pureProjection.toContinuousLinearMap.differentiableAt.comp p hd
  change DifferentiableAt ℝ (fun q => pureProjection (weightActionRaw (w q) (x q))) p at hp
  simpa only [weightActionRaw_pure, pureProjection_pure] using hp

/-- Entire finite neuron with jointly changing weights, signals and threshold. -/
theorem neuron_parametric_differentiableAt {ι : Type*} [Fintype ι]
    {w : P → ι → H} {x : P → ι → Pure} {θ : P → Pure}
    (hw : ∀ i, DifferentiableAt ℝ (fun q => w q i) p)
    (hx : DifferentiableAt ℝ x p) (hθ : DifferentiableAt ℝ θ p)
    (h0 : ∀ i, w p i ≠ 0) :
    DifferentiableAt ℝ (fun q => neuron (w q) (θ q) (x q)) p := by
  have hs : DifferentiableAt ℝ (fun q => ∑ i, weightAction (w q i) (x q i)) p :=
    DifferentiableAt.fun_sum (fun i _ =>
      weightAction_parametric_differentiableAt (hw i) (differentiableAt_pi.mp hx i) (h0 i))
  exact (activation_differentiable _).comp p (hs.sub hθ)

namespace Network

/-- All weights may vary jointly with a real parameter, and the input may vary too.
    The topology of the supplied parameter space governs the differentiability claim. -/
theorem mapWeights_parametric_differentiableAt {m n : ℕ} (N : Network m n)
    {f : P → WeightIndex N → H} {x : P → Signal m}
    (hf : ∀ e, DifferentiableAt ℝ (fun q => f q e) p)
    (hx : DifferentiableAt ℝ x p) (h0 : ∀ e, f p e ≠ 0) :
    DifferentiableAt ℝ (fun q => (N.mapWeights (f q)).euclideanForward (x q)) p := by
  induction N with
  | single L =>
    have hx' := (signalCoordinates m).toContinuousLinearMap.differentiableAt.comp p hx
    have hy : DifferentiableAt ℝ (fun q =>
        fun j => neuron (fun i => f q (.single L j i)) (L.thresholds j)
          (signalCoordinates m (x q))) p := by
      apply differentiableAt_pi.mpr
      intro j
      exact neuron_parametric_differentiableAt (fun i => hf (.single L j i)) hx'
        (differentiableAt_const _) (fun i => h0 (.single L j i))
    exact (signalCoordinates _).symm.toContinuousLinearMap.differentiableAt.comp p hy
  | @append k n N L ih =>
    have hxN := ih (fun e => hf (.earlier N L e)) (fun e => h0 (.earlier N L e))
    have hx' := (signalCoordinates k).toContinuousLinearMap.differentiableAt.comp p hxN
    have hy : DifferentiableAt ℝ (fun q =>
        fun j => neuron (fun i => f q (.last N L j i)) (L.thresholds j)
          (signalCoordinates k ((N.mapWeights (fun e => f q (.earlier N L e))).euclideanForward (x q)))) p := by
      apply differentiableAt_pi.mpr
      intro j
      exact neuron_parametric_differentiableAt (fun i => hf (.last N L j i)) hx'
        (differentiableAt_const _) (fun i => h0 (.last N L j i))
    have hd := (signalCoordinates n).symm.toContinuousLinearMap.differentiableAt.comp p hy
    simpa only [mapWeights, append_euclideanForward, Layer.euclideanForward,
      euclideanForward, forward] using! hd
/-- The loss is also differentiable under simultaneous parameter changes. -/
theorem objective_parametric_differentiableAt {m n : ℕ} (N : Network m n)
    {f : P → WeightIndex N → H} {x : P → Signal m} (d : Signal n)
    (hf : ∀ e, DifferentiableAt ℝ (fun q => f q e) p)
    (hx : DifferentiableAt ℝ x p) (h0 : ∀ e, f p e ≠ 0) :
    DifferentiableAt ℝ (fun q => (N.mapWeights (f q)).objective (x q) d) p := by
  have hd := (((N.mapWeights_parametric_differentiableAt hf hx h0).sub_const d).norm_sq ℝ).const_mul
    (1 / 2 : ℝ)
  exact hd
end Network
end
end QNN
