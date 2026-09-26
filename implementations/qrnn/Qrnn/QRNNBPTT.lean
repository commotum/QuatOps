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

@[simp] theorem recurrentProjection_apply {d h o : ℕ} (p : QRNNParameterSpace d h o) :
    recurrentProjection p = (paramsOf p).recurrent := rfl
@[simp] theorem inputProjection_apply {d h o : ℕ} (p : QRNNParameterSpace d h o) :
    inputProjection p = (paramsOf p).input := rfl
@[simp] theorem outputProjection_apply {d h o : ℕ} (p : QRNNParameterSpace d h o) :
    outputProjection p = (paramsOf p).output := rfl
@[simp] theorem biasProjection_apply {d h o : ℕ} (p : QRNNParameterSpace d h o) :
    biasProjection p = (paramsOf p).bias := rfl

/-- Partial derivative in the shared parameters before adding state dependence. -/
def qrnnParameterDerivative {d h o : ℕ} (x : QVector d) (s : QVector h)
    (df : Fin h → Fin 4 → ℝ) : QRNNParameterSpace d h o →L[ℝ] QVector h :=
  (vectorSplitDerivative df).comp
    ((weightActionCLM s).comp recurrentProjection +
      (weightActionCLM x).comp inputProjection + biasProjection)

@[simp] theorem qrnnParameterDerivative_apply {d h o : ℕ} (x : QVector d) (s : QVector h)
    (df : Fin h → Fin 4 → ℝ) (dp : QRNNParameterSpace d h o) :
    qrnnParameterDerivative x s df dp = vectorSplitDerivative df
      ((paramsOf dp).recurrent.mulVec s + (paramsOf dp).input.mulVec x + (paramsOf dp).bias) := by
  simp only [qrnnParameterDerivative, ContinuousLinearMap.comp_apply, add_apply,
    weightActionCLM_apply, recurrentProjection_apply, inputProjection_apply, biasProjection_apply]

@[simp] theorem qrnnStateDerivative_apply {d h o : ℕ} (p : QRNNParams d h o)
    (df : Fin h → Fin 4 → ℝ) (ds : QVector h) :
    qrnnStateDerivative p df ds = vectorSplitDerivative df (p.recurrent.mulVec ds) := by
  simp only [qrnnStateDerivative, ContinuousLinearMap.comp_apply, matrixActionCLM_apply]

/-- The real joint Jacobian of the step. The following theorem proves its
existence under the scalar activation hypotheses. Component evaluation of its
partial maps is a separate remaining gradient reconstruction task. -/
def qrnnJointDerivative {d h o : ℕ} (p : QRNNParameterSpace d h o) (f : ℝ → ℝ) (x : QVector d)
    (s : QVector h) : (QRNNParameterSpace d h o × QVector h) →L[ℝ] QVector h :=
  realFDeriv (fun z : QRNNParameterSpace d h o × QVector h => qrnnStep (paramsOf z.1) f x z.2) (p, s)

/-- The actual joint real derivative of a QRNN step. -/
theorem qrnnStep_joint_hasFDerivAt {d h o : ℕ} (p : QRNNParameterSpace d h o) (f : ℝ → ℝ)
    (x : QVector d) (s : QVector h) (df : Fin h → Fin 4 → ℝ)
    (hf : ∀ i a, HasDerivAt f (df i a) (components (hiddenPreact (paramsOf p) x s i) a)) :
    HasRealDerivative (fun z : QRNNParameterSpace d h o × QVector h =>
      qrnnStep (paramsOf z.1) f x z.2)
      (qrnnJointDerivative p f x s)
      (p, s) := by
  unfold HasRealDerivative
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
  unfold qrnnJointDerivative realFDeriv
  convert! ((vectorActivation_hasFDerivAt f (hiddenPreact (paramsOf p) x s) df hf).comp
    (p, s) hz).differentiableAt.hasFDerivAt using 1


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
    (x : ℕ → QVector d) (initial : QVector h) (T : ℕ) :
    QRNNParameterSpace d h o →L[ℝ] QVector h :=
  unrollDerivative
    (fun k => parameterPartial (qrnnJointDerivative p f (x k) (qrnnRun (paramsOf p) f x initial k)))
    (fun k => statePartial (qrnnJointDerivative p f (x k) (qrnnRun (paramsOf p) f x initial k))) T

/-- Verified derivative of the actual QRNN state with respect to all shared
parameters. Output parameters have no effect on hidden states. -/
theorem qrnnRun_hasFDerivAt {d h o : ℕ} (p : QRNNParameterSpace d h o) (f : ℝ → ℝ)
    (x : ℕ → QVector d) (initial : QVector h) (df : ℕ → Fin h → Fin 4 → ℝ) (T : ℕ)
    (hf : ∀ k < T, ∀ i a, HasDerivAt f (df k i a)
      (components (hiddenPreact (paramsOf p) (x k) (qrnnRun (paramsOf p) f x initial k) i) a)) :
    HasRealDerivative (fun θ => qrnnRun (paramsOf θ) f x initial T)
      (qrnnRunDerivative p f x initial T) p := by
  unfold HasRealDerivative
  let step := fun (k : ℕ) (θ : QRNNParameterSpace d h o) (s : QVector h) =>
    qrnnStep (paramsOf θ) f (x k) s
  have ht := unroll_hasFDerivAt step initial p
    (fun k => parameterPartial (qrnnJointDerivative p f (x k) (qrnnRun (paramsOf p) f x initial k)))
    (fun k => statePartial (qrnnJointDerivative p f (x k) (qrnnRun (paramsOf p) f x initial k))) T
    (fun k hk => by
      rw [split_joint_partials]
      simpa only [HasRealDerivative, step, unroll_eq_qrnnRun] using
        qrnnStep_joint_hasFDerivAt p f (x k) (qrnnRun (paramsOf p) f x initial k) (df k) (hf k hk))
  have he : unroll step initial T = (fun θ : QRNNParameterSpace d h o =>
      qrnnRun (paramsOf θ) f x initial T) := funext (unroll_eq_qrnnRun f x initial T)
  rw [he] at ht
  exact ht

/-- Reverse pullback for a terminal functional on the hidden state. The actual
Jacobian partials are used; their compact quaternion gradient evaluation remains
an additional theorem, not an assumption of this algorithm. -/
def qrnnBpttPullback {d h o : ℕ} (p : QRNNParameterSpace d h o) (f : ℝ → ℝ)
    (x : ℕ → QVector d) (initial : QVector h) (T : ℕ) (g : QVector h →L[ℝ] ℝ) :
    QRNNParameterSpace d h o →L[ℝ] ℝ :=
  bpttPullback
    (fun k => parameterPartial (qrnnJointDerivative p f (x k) (qrnnRun (paramsOf p) f x initial k)))
    (fun k => statePartial (qrnnJointDerivative p f (x k) (qrnnRun (paramsOf p) f x initial k))) T g

theorem qrnnBptt_correct {d h o : ℕ} (p : QRNNParameterSpace d h o) (f : ℝ → ℝ)
    (x : ℕ → QVector d) (initial : QVector h) (T : ℕ) (g : QVector h →L[ℝ] ℝ) :
    qrnnBpttPullback p f x initial T g = g.comp (qrnnRunDerivative p f x initial T) :=
  bptt_correct _ _ T g

/-- Correctness of QBPTT as the real derivative of a specified terminal hidden-state
loss. A variable output head additionally contributes a direct parameter term;
this theorem deliberately keeps that contribution outside the state-loss model. -/
theorem qrnnTerminalStateLoss_hasFDerivAt {d h o : ℕ} (p : QRNNParameterSpace d h o) (f : ℝ → ℝ)
    (x : ℕ → QVector d) (initial : QVector h) (df : ℕ → Fin h → Fin 4 → ℝ) (T : ℕ)
    (loss : QVector h → ℝ) (g : QVector h →L[ℝ] ℝ)
    (hf : ∀ k < T, ∀ i a, HasDerivAt f (df k i a)
      (components (hiddenPreact (paramsOf p) (x k) (qrnnRun (paramsOf p) f x initial k) i) a))
    (hl : HasRealDerivative loss g (qrnnRun (paramsOf p) f x initial T)) :
    HasRealDerivative (fun θ => loss (qrnnRun (paramsOf θ) f x initial T))
      (qrnnBpttPullback p f x initial T g) p := by
  unfold HasRealDerivative at hl ⊢
  rw [qrnnBptt_correct]
  exact hl.comp p (qrnnRun_hasFDerivAt p f x initial df T hf)

end
end Qrnn
