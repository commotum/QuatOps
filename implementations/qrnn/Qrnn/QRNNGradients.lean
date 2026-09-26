import Qrnn.QRNNBPTT

/-!
# Real derivatives and explicit shared-parameter quaternion gradients

All gradient identifications use Euclidean pairings of the four real components.
The scalar loss and differentiation hypotheses are stated separately from the
algebraic pullback identities.
-/

namespace Qrnn
open scoped Matrix.Norms.Elementwise
attribute [local instance] calculusAddCommGroup calculusModule
noncomputable section

/-- Evaluation of the actual real joint Jacobian of the QRNN step. -/
theorem qrnnJointDerivative_apply {d h o : ℕ} (p : QRNNParameterSpace d h o) (f : ℝ → ℝ)
    (x : QVector d) (s : QVector h) (df : Fin h → Fin 4 → ℝ)
    (hf : ∀ i a, HasDerivAt f (df i a) (components (hiddenPreact (paramsOf p) x s i) a))
    (v : QRNNParameterSpace d h o × QVector h) :
    qrnnJointDerivative p f x s v = vectorSplitDerivative df
      ((paramsOf v.1).recurrent.mulVec s + (paramsOf p).recurrent.mulVec v.2 +
        (paramsOf v.1).input.mulVec x + (paramsOf v.1).bias) := by
  let fst : (QRNNParameterSpace d h o × QVector h) →L[ℝ] QRNNParameterSpace d h o :=
    ContinuousLinearMap.fst ℝ _ _
  let snd : (QRNNParameterSpace d h o × QVector h) →L[ℝ] QVector h :=
    ContinuousLinearMap.snd ℝ _ _
  have hr := (recurrentProjection (d := d) (h := h) (o := o)).hasFDerivAt.comp (p, s) fst.hasFDerivAt
  have hi := (inputProjection (d := d) (h := h) (o := o)).hasFDerivAt.comp (p, s) fst.hasFDerivAt
  have hb := (biasProjection (d := d) (h := h) (o := o)).hasFDerivAt.comp (p, s) fst.hasFDerivAt
  have hs := snd.hasFDerivAt (x := (p, s))
  have hx := hasFDerivAt_const (𝕜 := ℝ) x (p, s)
  have hrec := matVec_hasFDerivAt
    (fun z => recurrentProjection (d := d) (h := h) (o := o) (fst z)) snd (p, s)
    (recurrentProjection.comp fst) snd hr hs
  have hin := matVec_hasFDerivAt
    (fun z => inputProjection (d := d) (h := h) (o := o) (fst z)) (fun _ => x) (p, s)
    (inputProjection.comp fst) 0 hi hx
  have hz := (hrec.add hin).add hb
  have hd := (vectorActivation_hasFDerivAt f (hiddenPreact (paramsOf p) x s) df hf).comp
    (p, s) hz
  have he := congrArg (fun D => D v) hd.fderiv
  simpa only [qrnnJointDerivative, realFDeriv, qrnnStep, hiddenPreact,
    ContinuousLinearMap.comp_apply, add_apply, matVecDerivative_apply,
    recurrentProjection_apply, inputProjection_apply, biasProjection_apply,
    ContinuousLinearMap.coe_fst', ContinuousLinearMap.coe_snd', Function.comp_def,
    Pi.add_apply,
    zero_apply, Matrix.mulVec_zero, add_zero, fst, snd] using he

end
end Qrnn
