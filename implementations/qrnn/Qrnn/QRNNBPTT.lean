import Qrnn.BPTT

/-!
# QRNN shared parameter space and the BPTT bridge

All four independent real-component parameter families are explicit. A fixed
initial state has zero parameter derivative. Gradients are relative to the
Euclidean pairings, whereas the parameter topology uses finite product norms.
-/

namespace Qrnn
open scoped Matrix.Norms.Elementwise
attribute [local instance] calculusAddCommGroup calculusModule
noncomputable section

abbrev QRNNParameterSpace (d h o : ℕ) :=
  QMatrix h h × (QMatrix h d × (QMatrix o h × QVector h))

def paramsOf {d h o : ℕ} (p : QRNNParameterSpace d h o) : QRNNParams d h o :=
  ⟨p.1, p.2.1, p.2.2.1, p.2.2.2⟩

def paramsToSpace {d h o : ℕ} (p : QRNNParams d h o) : QRNNParameterSpace d h o :=
  (p.recurrent, p.input, p.output, p.bias)

@[simp] theorem paramsOf_toSpace {d h o : ℕ} (p : QRNNParams d h o) :
    paramsOf (paramsToSpace p) = p := by cases p; rfl

@[simp] theorem paramsToSpace_of {d h o : ℕ} (p : QRNNParameterSpace d h o) :
    paramsToSpace (paramsOf p) = p := rfl

def recurrentProjection {d h o : ℕ} : QRNNParameterSpace d h o →L[ℝ] QMatrix h h :=
  ContinuousLinearMap.fst ℝ _ _

def inputProjection {d h o : ℕ} : QRNNParameterSpace d h o →L[ℝ] QMatrix h d :=
  (ContinuousLinearMap.fst ℝ _ _).comp (ContinuousLinearMap.snd ℝ _ _)

def outputProjection {d h o : ℕ} : QRNNParameterSpace d h o →L[ℝ] QMatrix o h :=
  (ContinuousLinearMap.fst ℝ _ _).comp
    ((ContinuousLinearMap.snd ℝ _ _).comp (ContinuousLinearMap.snd ℝ _ _))

def biasProjection {d h o : ℕ} : QRNNParameterSpace d h o →L[ℝ] QVector h :=
  (ContinuousLinearMap.snd ℝ _ _).comp
    ((ContinuousLinearMap.snd ℝ _ _).comp (ContinuousLinearMap.snd ℝ _ _))

/-- Partial derivative in the shared parameters before adding state dependence. -/
def qrnnParameterDerivative {d h o : ℕ} (x : QVector d) (s : QVector h)
    (df : Fin h → Fin 4 → ℝ) : QRNNParameterSpace d h o →L[ℝ] QVector h :=
  (vectorSplitDerivative df).comp
    ((weightActionCLM s).comp recurrentProjection +
      (weightActionCLM x).comp inputProjection + biasProjection)

/-- The actual joint real derivative of a QRNN step. -/
set_option maxHeartbeats 800000 in
theorem qrnnStep_joint_hasFDerivAt {d h o : ℕ} (p : QRNNParameterSpace d h o) (f : ℝ → ℝ)
    (x : QVector d) (s : QVector h) (df : Fin h → Fin 4 → ℝ)
    (hf : ∀ i a, HasDerivAt f (df i a) (components (hiddenPreact (paramsOf p) x s i) a)) :
    HasFDerivAt (fun z : QRNNParameterSpace d h o × QVector h =>
      qrnnStep (paramsOf z.1) f x z.2)
      (jointStepDerivative (qrnnParameterDerivative x s df) (qrnnStateDerivative (paramsOf p) df))
      (p, s) := by
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
  convert! (vectorActivation_hasFDerivAt f (hiddenPreact (paramsOf p) x s) df hf).comp (p, s) hz using 1
  apply ContinuousLinearMap.ext
  intro v
  simp [jointStepDerivative, qrnnParameterDerivative, qrnnStateDerivative, matVecDerivative,
    fst, snd, paramsOf, recurrentProjection, inputProjection, biasProjection,
    ContinuousLinearMap.comp_apply, map_add, add_assoc, add_comm, add_left_comm]

/-- The generic unroll is the actual QRNN recurrence for packed parameters. -/
theorem unroll_eq_qrnnRun {d h o : ℕ} (f : ℝ → ℝ) (x : ℕ → QVector d)
    (initial : QVector h) (T : ℕ) (p : QRNNParameterSpace d h o) :
    unroll (fun k θ s => qrnnStep (paramsOf θ) f (x k) s) initial T p =
      qrnnRun (paramsOf p) f x initial T := by
  induction T with
  | zero => rfl
  | succ T ih => simp [unroll, qrnnRun, ih]

/-- Forward state sensitivity over the shared recurrent/input/bias parameters. -/
def qrnnRunDerivative {d h o : ℕ} (p : QRNNParameterSpace d h o) (f : ℝ → ℝ)
    (x : ℕ → QVector d) (initial : QVector h) (df : ℕ → Fin h → Fin 4 → ℝ) (T : ℕ) :
    QRNNParameterSpace d h o →L[ℝ] QVector h :=
  unrollDerivative
    (fun k => qrnnParameterDerivative (x k) (qrnnRun (paramsOf p) f x initial k) (df k))
    (fun k => qrnnStateDerivative (paramsOf p) (df k)) T

/-- Verified derivative of the actual QRNN state with respect to all shared
parameters. Output parameters have no effect on hidden states. -/
theorem qrnnRun_hasFDerivAt {d h o : ℕ} (p : QRNNParameterSpace d h o) (f : ℝ → ℝ)
    (x : ℕ → QVector d) (initial : QVector h) (df : ℕ → Fin h → Fin 4 → ℝ) (T : ℕ)
    (hf : ∀ k < T, ∀ i a, HasDerivAt f (df k i a)
      (components (hiddenPreact (paramsOf p) (x k) (qrnnRun (paramsOf p) f x initial k) i) a)) :
    HasFDerivAt (fun θ => qrnnRun (paramsOf θ) f x initial T)
      (qrnnRunDerivative p f x initial df T) p := by
  let step := fun (k : ℕ) (θ : QRNNParameterSpace d h o) (s : QVector h) =>
    qrnnStep (paramsOf θ) f (x k) s
  have ht := unroll_hasFDerivAt step initial p
    (fun k => qrnnParameterDerivative (x k) (qrnnRun (paramsOf p) f x initial k) (df k))
    (fun k => qrnnStateDerivative (paramsOf p) (df k)) T
    (fun k hk => by
      simpa only [step, unroll_eq_qrnnRun] using
        qrnnStep_joint_hasFDerivAt p f (x k) (qrnnRun (paramsOf p) f x initial k) (df k) (hf k hk))
  simpa only [step, unroll_eq_qrnnRun, qrnnRunDerivative] using ht

end
end Qrnn
