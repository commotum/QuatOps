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
  simp only [ContinuousLinearMap.comp_apply, add_apply, matVecDerivative_apply,
    recurrentProjection_apply, inputProjection_apply, biasProjection_apply,
    ContinuousLinearMap.coe_fst', ContinuousLinearMap.coe_snd', Function.comp_def,
    Pi.add_apply,
    zero_apply, Matrix.mulVec_zero, add_zero, fst, snd] at he
  exact he

/-- Parameter partial of the joint Jacobian, evaluated on a direction. -/
theorem qrnnParameterPartial_apply {d h o : ℕ} (p : QRNNParameterSpace d h o) (f : ℝ → ℝ)
    (x : QVector d) (s : QVector h) (df : Fin h → Fin 4 → ℝ)
    (hf : ∀ i a, HasDerivAt f (df i a) (components (hiddenPreact (paramsOf p) x s i) a))
    (dp : QRNNParameterSpace d h o) :
    parameterPartial (qrnnJointDerivative p f x s) dp = qrnnParameterDerivative x s df dp := by
  change qrnnJointDerivative p f x s (dp, 0) = _
  rw [qrnnJointDerivative_apply p f x s df hf]
  simp only [qrnnParameterDerivative_apply, Matrix.mulVec_zero, add_zero]

/-- State partial of the joint Jacobian, evaluated on a direction. -/
theorem qrnnStatePartial_apply {d h o : ℕ} (p : QRNNParameterSpace d h o) (f : ℝ → ℝ)
    (x : QVector d) (s : QVector h) (df : Fin h → Fin 4 → ℝ)
    (hf : ∀ i a, HasDerivAt f (df i a) (components (hiddenPreact (paramsOf p) x s i) a))
    (ds : QVector h) :
    statePartial (qrnnJointDerivative p f x s) ds = qrnnStateDerivative (paramsOf p) df ds := by
  change qrnnJointDerivative p f x s (0, ds) = _
  rw [qrnnJointDerivative_apply p f x s df hf]
  simp [qrnnStateDerivative_apply, paramsOf]

/-- Euclidean pairing on all independent parameter coordinates, including the output head. -/
def parameterPair {d h o : ℕ} (dp g : QRNNParameterSpace d h o) : ℝ :=
  matrixPair dp.1 g.1 + matrixPair dp.2.1 g.2.1 +
    matrixPair dp.2.2.1 g.2.2.1 + vectorPair dp.2.2.2 g.2.2.2

/-- Hidden preactivation cotangent contributes to recurrent/input/bias parameters.
The output matrix is absent from this step, so its local gradient is zero. -/
def stepParameterGradient {d h o : ℕ} (x : QVector d) (s : QVector h)
    (df : Fin h → Fin 4 → ℝ) (g : QVector h) : QRNNParameterSpace d h o :=
  let δ := vectorSplitDerivative df g
  (weightOuter δ s, weightOuter δ x, 0, δ)

private theorem realPair_add_left (p q g : Q) :
    realPair (p+q) g = realPair p g + realPair q g := by
  simp only [realPair, components_add, Pi.add_apply, add_mul, Finset.sum_add_distrib]

private theorem realPair_add_right (v p q : Q) :
    realPair v (p+q) = realPair v p + realPair v q := by
  simp only [realPair, components_add, Pi.add_apply, mul_add, Finset.sum_add_distrib]

private theorem vectorPair_add_left {n : ℕ} (v w g : QVector n) :
    vectorPair (v+w) g = vectorPair v g + vectorPair w g := by
  simp only [vectorPair, Pi.add_apply, realPair_add_left, Finset.sum_add_distrib]

private theorem parameterPair_add_right {d h o : ℕ} (dp a b : QRNNParameterSpace d h o) :
    parameterPair dp (a+b) = parameterPair dp a + parameterPair dp b := by
  simp only [parameterPair, matrixPair, vectorPair, Prod.fst_add, Prod.snd_add,
    Pi.add_apply, Matrix.add_apply, realPair_add_right, Finset.sum_add_distrib]
  ring

private theorem parameterPair_zero {d h o : ℕ} (dp : QRNNParameterSpace d h o) :
    parameterPair dp 0 = 0 := by
  simp [parameterPair, matrixPair, vectorPair, realPair, components_zero]

/-- Euclidean gradient of a single step's parameter partial. -/
theorem qrnnParameterDerivative_pair {d h o : ℕ} (x : QVector d) (s : QVector h)
    (df : Fin h → Fin 4 → ℝ) (dp : QRNNParameterSpace d h o) (g : QVector h) :
    vectorPair (qrnnParameterDerivative x s df dp) g =
      parameterPair dp (stepParameterGradient x s df g) := by
  rw [qrnnParameterDerivative_apply, vectorSplitDerivative_pair,
    vectorPair_add_left, vectorPair_add_left, matrix_weight_pair, matrix_weight_pair]
  simp [parameterPair, stepParameterGradient, paramsOf, matrixPair, realPair, components_zero]

/-- Euclidean hidden cotangent, bundled as an ordinary real-linear functional. -/
def vectorCotangent {n : ℕ} (g : QVector n) : QVector n →L[ℝ] ℝ := lossDerivative 0 g

@[simp] theorem vectorCotangent_apply {n : ℕ} (g v : QVector n) :
    vectorCotangent g v = vectorPair v g := by simp [vectorCotangent, lossDerivative_pair]

/-- Explicit reverse accumulation of the recurrent/input/bias gradients.
At step k the previous state is h_k and the input is x_k, not terminal-time data.
The caller supplies the terminal hidden-state cotangent g. -/
def quaternionBpttGradient {d h o : ℕ} (p : QRNNParams d h o) (f : ℝ → ℝ)
    (x : ℕ → QVector d) (initial : QVector h) (df : ℕ → Fin h → Fin 4 → ℝ) :
    ℕ → QVector h → QRNNParameterSpace d h o
  | 0, _ => 0
  | k+1, g =>
    quaternionBpttGradient p f x initial df k
      (p.recurrent.conjTranspose.mulVec (vectorSplitDerivative (df k) g)) +
    stepParameterGradient (x k) (qrnnRun p f x initial k) (df k) g

/-- The explicit quaternion accumulation is the generic real BPTT differential. -/
theorem quaternionBpttGradient_correct {d h o : ℕ} (p : QRNNParameterSpace d h o)
    (f : ℝ → ℝ) (x : ℕ → QVector d) (initial : QVector h)
    (df : ℕ → Fin h → Fin 4 → ℝ) (T : ℕ)
    (hf : ∀ k < T, ∀ i a, HasDerivAt f (df k i a)
      (components (hiddenPreact (paramsOf p) (x k) (qrnnRun (paramsOf p) f x initial k) i) a))
    (g : QVector h) (dp : QRNNParameterSpace d h o) :
    qrnnBpttPullback p f x initial T (vectorCotangent g) dp =
      parameterPair dp (quaternionBpttGradient (paramsOf p) f x initial df T g) := by
  induction T generalizing g with
  | zero => exact (parameterPair_zero dp).symm
  | succ T ih =>
    have hs : (vectorCotangent g).comp
        (statePartial (qrnnJointDerivative p f (x T) (qrnnRun (paramsOf p) f x initial T))) =
        vectorCotangent ((paramsOf p).recurrent.conjTranspose.mulVec (vectorSplitDerivative (df T) g)) := by
      apply DFunLike.ext
      intro v
      simp only [ContinuousLinearMap.comp_apply, vectorCotangent_apply,
        qrnnStatePartial_apply p f (x T) (qrnnRun (paramsOf p) f x initial T) (df T)
          (hf T (Nat.lt_succ_self T)), qrnnStateDerivative_pair]
    change (bpttPullback _ _ T _ + _ ) dp = _
    rw [add_apply, hs]
    change qrnnBpttPullback p f x initial T
      (vectorCotangent ((paramsOf p).recurrent.conjTranspose.mulVec (vectorSplitDerivative (df T) g))) dp +
      vectorCotangent g (parameterPartial
        (qrnnJointDerivative p f (x T) (qrnnRun (paramsOf p) f x initial T)) dp) = _
    rw [ih (fun k hk => hf k (Nat.lt_trans hk (Nat.lt_succ_self T))),
      qrnnParameterPartial_apply p f (x T) (qrnnRun (paramsOf p) f x initial T) (df T)
        (hf T (Nat.lt_succ_self T)), vectorCotangent_apply, qrnnParameterDerivative_pair]
    exact (parameterPair_add_right dp _ _).symm

/-- Actual terminal half-squared output loss, with a variable shared output head. -/
def qrnnTerminalLoss {d h o : ℕ} (p : QRNNParameterSpace d h o) (f β : ℝ → ℝ)
    (x : ℕ → QVector d) (initial : QVector h) (T : ℕ) (y : QVector o) : ℝ :=
  halfSquaredLoss y (qrnnReadout (paramsOf p) β (qrnnRun (paramsOf p) f x initial T))

/-- Direct output-weight contribution on the full parameter space. -/
def outputParameterGradient {d h o : ℕ} (s : QVector h) (δ : QVector o) :
    QRNNParameterSpace d h o := (0, 0, weightOuter δ s, 0)

/-- Complete terminal gradient: hidden BPTT plus the direct output-weight term. -/
def qrnnTerminalGradient {d h o : ℕ} (p : QRNNParams d h o) (f β : ℝ → ℝ)
    (x : ℕ → QVector d) (initial : QVector h) (df : ℕ → Fin h → Fin 4 → ℝ)
    (T : ℕ) (y : QVector o) (dβ : Fin o → Fin 4 → ℝ) : QRNNParameterSpace d h o :=
  let s := qrnnRun p f x initial T
  let δ := vectorSplitDerivative dβ (qrnnReadout p β s - y)
  quaternionBpttGradient p f x initial df T (p.output.conjTranspose.mulVec δ) +
    outputParameterGradient s δ

/-- Differentiability of the actual terminal loss, including shared output weights. -/
theorem qrnnTerminalLoss_hasFDerivAt {d h o : ℕ} (p : QRNNParameterSpace d h o)
    (f β : ℝ → ℝ) (x : ℕ → QVector d) (initial : QVector h)
    (df : ℕ → Fin h → Fin 4 → ℝ) (T : ℕ) (y : QVector o) (dβ : Fin o → Fin 4 → ℝ)
    (hf : ∀ k < T, ∀ i a, HasDerivAt f (df k i a)
      (components (hiddenPreact (paramsOf p) (x k) (qrnnRun (paramsOf p) f x initial k) i) a))
    (hβ : ∀ i a, HasDerivAt β (dβ i a)
      (components ((paramsOf p).output.mulVec (qrnnRun (paramsOf p) f x initial T) i) a)) :
    HasRealDerivative (fun θ => qrnnTerminalLoss θ f β x initial T y)
      (realFDeriv (fun θ => qrnnTerminalLoss θ f β x initial T y) p) p := by
  have hs := qrnnRun_hasFDerivAt p f x initial df T hf
  have ho := (outputProjection (d := d) (h := h) (o := o)).hasFDerivAt (x := p)
  have hz := matVec_hasFDerivAt outputProjection
    (fun θ => qrnnRun (paramsOf θ) f x initial T) p outputProjection
    (qrnnRunDerivative p f x initial T) ho hs
  have ha := (vectorActivation_hasFDerivAt β
    ((paramsOf p).output.mulVec (qrnnRun (paramsOf p) f x initial T)) dβ hβ).comp p hz
  have hl := (halfSquaredLoss_hasFDerivAt y
    (qrnnReadout (paramsOf p) β (qrnnRun (paramsOf p) f x initial T))).comp p ha
  exact hl.differentiableAt.hasFDerivAt

private theorem outputParameterGradient_pair {d h o : ℕ} (dp : QRNNParameterSpace d h o)
    (s : QVector h) (δ : QVector o) :
    parameterPair dp (outputParameterGradient s δ) = matrixPair dp.2.2.1 (weightOuter δ s) := by
  simp [parameterPair, outputParameterGradient, matrixPair, vectorPair, realPair, components_zero]

/-- The real differential of terminal output loss is the Euclidean pairing with
all four explicit quaternion parameter gradients. The assertion holds for every
real parameter direction, so this identifies the full componentwise gradient. -/
theorem qrnnTerminalGradient_correct {d h o : ℕ} (p : QRNNParameterSpace d h o)
    (f β : ℝ → ℝ) (x : ℕ → QVector d) (initial : QVector h)
    (df : ℕ → Fin h → Fin 4 → ℝ) (T : ℕ) (y : QVector o) (dβ : Fin o → Fin 4 → ℝ)
    (hf : ∀ k < T, ∀ i a, HasDerivAt f (df k i a)
      (components (hiddenPreact (paramsOf p) (x k) (qrnnRun (paramsOf p) f x initial k) i) a))
    (hβ : ∀ i a, HasDerivAt β (dβ i a)
      (components ((paramsOf p).output.mulVec (qrnnRun (paramsOf p) f x initial T) i) a))
    (dp : QRNNParameterSpace d h o) :
    realFDeriv (fun θ => qrnnTerminalLoss θ f β x initial T y) p dp =
      parameterPair dp (qrnnTerminalGradient (paramsOf p) f β x initial df T y dβ) := by
  have hs := qrnnRun_hasFDerivAt p f x initial df T hf
  have ho := (outputProjection (d := d) (h := h) (o := o)).hasFDerivAt (x := p)
  have hz := matVec_hasFDerivAt outputProjection
    (fun θ => qrnnRun (paramsOf θ) f x initial T) p outputProjection
    (qrnnRunDerivative p f x initial T) ho hs
  have ha := (vectorActivation_hasFDerivAt β
    ((paramsOf p).output.mulVec (qrnnRun (paramsOf p) f x initial T)) dβ hβ).comp p hz
  have hl := (halfSquaredLoss_hasFDerivAt y
    (qrnnReadout (paramsOf p) β (qrnnRun (paramsOf p) f x initial T))).comp p ha
  have he := congrArg (fun D => D dp) hl.fderiv
  simp only [ContinuousLinearMap.comp_apply, lossDerivative_pair,
    matVecDerivative_apply, outputProjection_apply] at he
  change realFDeriv (fun θ => qrnnTerminalLoss θ f β x initial T y) p dp = _ at he
  rw [he, vectorSplitDerivative_pair, vectorPair_add_left,
    matrix_weight_pair, matrix_mul_pair]
  have hb := quaternionBpttGradient_correct p f x initial df T hf
    ((paramsOf p).output.conjTranspose.mulVec
      (vectorSplitDerivative dβ
        (qrnnReadout (paramsOf p) β (qrnnRun (paramsOf p) f x initial T) - y))) dp
  rw [qrnnBptt_correct, ContinuousLinearMap.comp_apply, vectorCotangent_apply] at hb
  change matrixPair dp.2.2.1 _ + vectorPair _ _ = _
  refine (congrArg (fun a : ℝ => matrixPair dp.2.2.1
    (weightOuter (vectorSplitDerivative dβ
      (qrnnReadout (paramsOf p) β (qrnnRun (paramsOf p) f x initial T) - y))
      (qrnnRun (paramsOf p) f x initial T)) + a) hb).trans ?_
  simp only [qrnnTerminalGradient, parameterPair_add_right, outputParameterGradient_pair]
  exact add_comm _ _

end
end Qrnn
