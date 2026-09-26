import Qrnn.Forward
import Mathlib.Analysis.Matrix.Normed
import Mathlib.Analysis.Calculus.FDeriv.Mul
import Mathlib.Analysis.Calculus.FDeriv.Add

/-!
# Local real derivatives and cotangent identities

Every derivative in this module is over ℝ. In particular, the output activation
cotangent is formed before multiplying by the conjugate-transposed output matrix.
-/

namespace Qrnn
open scoped Matrix.Norms.Elementwise
attribute [local instance] calculusAddCommGroup calculusModule
noncomputable section

/-- Quaternion matrix action bundled as a continuous ℝ-linear map. -/
def matrixActionCLM {m n : ℕ} (W : QMatrix m n) : QVector n →L[ℝ] QVector m :=
  ContinuousLinearMap.pi (fun i => ∑ j : Fin n,
    (ContinuousLinearMap.mul ℝ Q (W i j)).comp (ContinuousLinearMap.proj j))

@[simp] theorem matrixActionCLM_apply {m n : ℕ} (W : QMatrix m n) (x : QVector n) :
    matrixActionCLM W x = W.mulVec x := by
  funext i
  simp [matrixActionCLM, Matrix.mulVec, dotProduct]

/-- With the input fixed, the affine layer is also real-linear in its weights. -/
def weightActionCLM {m n : ℕ} (x : QVector n) : QMatrix m n →L[ℝ] QVector m :=
  ContinuousLinearMap.pi (fun i => ∑ j : Fin n,
    ((ContinuousLinearMap.mul ℝ Q).flip (x j)).comp
      ((ContinuousLinearMap.proj j : QVector n →L[ℝ] Q).comp
        (ContinuousLinearMap.proj i : QMatrix m n →L[ℝ] QVector n)))

@[simp] theorem weightActionCLM_apply {m n : ℕ} (x : QVector n) (W : QMatrix m n) :
    weightActionCLM x W = W.mulVec x := by
  funext i
  simp [weightActionCLM, Matrix.mulVec, dotProduct]
  rfl

theorem matrixAction_hasFDerivAt {m n : ℕ} (W : QMatrix m n) (x : QVector n) :
    HasFDerivAt W.mulVec (matrixActionCLM W) x := by
  have he : (fun v => matrixActionCLM W v) = W.mulVec :=
    funext (matrixActionCLM_apply W)
  rw [← he]
  exact (matrixActionCLM W).hasFDerivAt

theorem weightAction_hasFDerivAt {m n : ℕ} (W : QMatrix m n) (x : QVector n) :
    HasFDerivAt (fun A : QMatrix m n => A.mulVec x) (weightActionCLM x) W := by
  have he : (fun A => weightActionCLM x A) = (fun A : QMatrix m n => A.mulVec x) :=
    funext (weightActionCLM_apply x)
  rw [← he]
  exact (weightActionCLM x).hasFDerivAt

/-- Diagonal split derivative at every neuron. -/
def vectorSplitDerivative {n : ℕ} (d : Fin n → Fin 4 → ℝ) : QVector n →L[ℝ] QVector n :=
  ContinuousLinearMap.pi (fun i => (splitDerivative (d i)).comp (ContinuousLinearMap.proj i))

@[simp] theorem vectorSplitDerivative_apply {n : ℕ} (d : Fin n → Fin 4 → ℝ)
    (v : QVector n) (i : Fin n) : vectorSplitDerivative d v i = splitDerivative (d i) (v i) := rfl

theorem vectorActivation_hasFDerivAt {n : ℕ} (f : ℝ → ℝ) (v : QVector n)
    (d : Fin n → Fin 4 → ℝ)
    (hf : ∀ i a, HasDerivAt f (d i a) (components (v i) a)) :
    HasFDerivAt (vectorActivation f) (vectorSplitDerivative d) v := by
  apply hasFDerivAt_pi.mpr
  intro i
  exact (splitActivation_hasFDerivAt f (v i) (d i) (hf i)).comp v
    (hasFDerivAt_apply (𝕜 := ℝ) i v)

theorem vectorSplitDerivative_pair {n : ℕ} (d : Fin n → Fin 4 → ℝ) (v g : QVector n) :
    vectorPair (vectorSplitDerivative d v) g = vectorPair v (vectorSplitDerivative d g) := by
  simp only [vectorPair, vectorSplitDerivative_apply, splitDerivative_pair]

/-- Hidden derivative with respect to the previous state, at fixed parameters/input. -/
def qrnnStateDerivative {d h o : ℕ} (p : QRNNParams d h o)
    (df : Fin h → Fin 4 → ℝ) : QVector h →L[ℝ] QVector h :=
  (vectorSplitDerivative df).comp (matrixActionCLM p.recurrent)

theorem qrnnStep_state_hasFDerivAt {d h o : ℕ} (p : QRNNParams d h o) (f : ℝ → ℝ)
    (x : QVector d) (s : QVector h) (df : Fin h → Fin 4 → ℝ)
    (hf : ∀ i a, HasDerivAt f (df i a) (components (hiddenPreact p x s i) a)) :
    HasFDerivAt (qrnnStep p f x) (qrnnStateDerivative p df) s := by
  exact (vectorActivation_hasFDerivAt f (hiddenPreact p x s) df hf).comp s
    (((matrixAction_hasFDerivAt p.recurrent s).add_const (p.input.mulVec x)).add_const p.bias)

/-- Local recurrence cotangent: split activation first, recurrent adjoint second. -/
theorem qrnnStateDerivative_pair {d h o : ℕ} (p : QRNNParams d h o)
    (df : Fin h → Fin 4 → ℝ) (v g : QVector h) :
    vectorPair (qrnnStateDerivative p df v) g =
      vectorPair v (p.recurrent.conjTranspose.mulVec (vectorSplitDerivative df g)) := by
  simp only [qrnnStateDerivative, ContinuousLinearMap.comp_apply, matrixActionCLM_apply]
  rw [vectorSplitDerivative_pair, matrix_mul_pair]

/-- Output derivative with respect to the hidden state. -/
def readoutDerivative {d h o : ℕ} (p : QRNNParams d h o)
    (dβ : Fin o → Fin 4 → ℝ) : QVector h →L[ℝ] QVector o :=
  (vectorSplitDerivative dβ).comp (matrixActionCLM p.output)

theorem readout_hasFDerivAt {d h o : ℕ} (p : QRNNParams d h o) (β : ℝ → ℝ)
    (s : QVector h) (dβ : Fin o → Fin 4 → ℝ)
    (hβ : ∀ i a, HasDerivAt β (dβ i a) (components (p.output.mulVec s i) a)) :
    HasFDerivAt (qrnnReadout p β) (readoutDerivative p dβ) s :=
  (vectorActivation_hasFDerivAt β (p.output.mulVec s) dβ hβ).comp s
    (matrixAction_hasFDerivAt p.output s)

/-- Correct ordering of the readout pullback. The derivative is evaluated at the
output preactivation, not at the postactivation, and precedes the matrix adjoint. -/
theorem readoutDerivative_pair {d h o : ℕ} (p : QRNNParams d h o)
    (dβ : Fin o → Fin 4 → ℝ) (v : QVector h) (g : QVector o) :
    vectorPair (readoutDerivative p dβ v) g =
      vectorPair v (p.output.conjTranspose.mulVec (vectorSplitDerivative dβ g)) := by
  simp only [readoutDerivative, ContinuousLinearMap.comp_apply, matrixActionCLM_apply]
  rw [vectorSplitDerivative_pair, matrix_mul_pair]

/-- For fixed hidden state, output weight cotangent includes the readout derivative. -/
theorem output_weight_pair {h o : ℕ} (dβ : Fin o → Fin 4 → ℝ)
    (dW : QMatrix o h) (s : QVector h) (g : QVector o) :
    vectorPair (vectorSplitDerivative dβ (dW.mulVec s)) g =
      matrixPair dW (weightOuter (vectorSplitDerivative dβ g) s) := by
  rw [vectorSplitDerivative_pair, matrix_weight_pair]

/-- Recurrent-weight derivative for one step, with the previous state held fixed. -/
theorem recurrentWeight_hasFDerivAt {d h o : ℕ} (p : QRNNParams d h o) (f : ℝ → ℝ)
    (x : QVector d) (s : QVector h) (df : Fin h → Fin 4 → ℝ)
    (hf : ∀ i a, HasDerivAt f (df i a) (components (hiddenPreact p x s i) a)) :
    HasFDerivAt (fun W : QMatrix h h =>
      vectorActivation f (W.mulVec s + p.input.mulVec x + p.bias))
      ((vectorSplitDerivative df).comp (weightActionCLM s)) p.recurrent := by
  convert! (vectorActivation_hasFDerivAt f (hiddenPreact p x s) df hf).comp p.recurrent
    (((weightAction_hasFDerivAt p.recurrent s).add_const (p.input.mulVec x)).add_const p.bias) using 1

/-- Input-weight derivative for one step, with all states held fixed. -/
theorem inputWeight_hasFDerivAt {d h o : ℕ} (p : QRNNParams d h o) (f : ℝ → ℝ)
    (x : QVector d) (s : QVector h) (df : Fin h → Fin 4 → ℝ)
    (hf : ∀ i a, HasDerivAt f (df i a) (components (hiddenPreact p x s i) a)) :
    HasFDerivAt (fun W : QMatrix h d =>
      vectorActivation f (p.recurrent.mulVec s + W.mulVec x + p.bias))
      ((vectorSplitDerivative df).comp (weightActionCLM x)) p.input := by
  convert! (vectorActivation_hasFDerivAt f (hiddenPreact p x s) df hf).comp p.input
    (((weightAction_hasFDerivAt p.input x).const_add (p.recurrent.mulVec s)).add_const p.bias) using 1

/-- The additive-bias Jacobian is the identity before the split activation. -/
theorem bias_hasFDerivAt {d h o : ℕ} (p : QRNNParams d h o) (f : ℝ → ℝ)
    (x : QVector d) (s : QVector h) (df : Fin h → Fin 4 → ℝ)
    (hf : ∀ i a, HasDerivAt f (df i a) (components (hiddenPreact p x s i) a)) :
    HasFDerivAt (fun b : QVector h =>
      vectorActivation f (p.recurrent.mulVec s + p.input.mulVec x + b))
      (vectorSplitDerivative df) p.bias := by
  simpa using (vectorActivation_hasFDerivAt f (hiddenPreact p x s) df hf).comp p.bias
    ((hasFDerivAt_id p.bias).const_add (p.recurrent.mulVec s + p.input.mulVec x))

/-- Output-weight derivative with arbitrary differentiable split readout. -/
theorem layerWeight_hasFDerivAt {h o : ℕ} (W : QMatrix o h) (β : ℝ → ℝ)
    (s : QVector h) (dβ : Fin o → Fin 4 → ℝ)
    (hβ : ∀ i a, HasDerivAt β (dβ i a) (components (W.mulVec s i) a)) :
    HasFDerivAt (fun A : QMatrix o h => vectorActivation β (A.mulVec s))
      ((vectorSplitDerivative dβ).comp (weightActionCLM s)) W := by
  convert! (vectorActivation_hasFDerivAt β (W.mulVec s) dβ hβ).comp W
    (weightAction_hasFDerivAt W s) using 1

/-- Joint matrix/input derivative; the two contributions retain Hamilton order. -/
def matVecDerivative {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {m n : ℕ} (W : QMatrix m n) (x : QVector n)
    (dW : E →L[ℝ] QMatrix m n) (dx : E →L[ℝ] QVector n) : E →L[ℝ] QVector m :=
  (weightActionCLM x).comp dW + (matrixActionCLM W).comp dx

@[simp] theorem matVecDerivative_apply {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {m n : ℕ} (W : QMatrix m n) (x : QVector n)
    (dW : E →L[ℝ] QMatrix m n) (dx : E →L[ℝ] QVector n) (v : E) :
    matVecDerivative W x dW dx v = (dW v).mulVec x + W.mulVec (dx v) := by
  simp [matVecDerivative]

/-- Ordinary real product rule for an entire quaternion matrix/vector product. -/
theorem matVec_hasFDerivAt {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {m n : ℕ} (W : E → QMatrix m n) (x : E → QVector n) (z : E)
    (dW : E →L[ℝ] QMatrix m n) (dx : E →L[ℝ] QVector n)
    (hW : HasFDerivAt W dW z) (hx : HasFDerivAt x dx z) :
    HasFDerivAt (fun t => (W t).mulVec (x t)) (matVecDerivative (W z) (x z) dW dx) z := by
  apply hasFDerivAt_pi'.mpr
  intro i
  have hwrow := (hasFDerivAt_apply (𝕜 := ℝ) i (W z)).comp z hW
  have hs := HasFDerivAt.fun_sum (u := Finset.univ) (fun j (_ : j ∈ Finset.univ) =>
    (((hasFDerivAt_apply (𝕜 := ℝ) j (W z i)).comp z hwrow).mul'
      ((hasFDerivAt_apply (𝕜 := ℝ) j (x z)).comp z hx)))
  convert! hs using 1
  apply ContinuousLinearMap.ext
  intro v
  simp [matVecDerivative, weightActionCLM, matrixActionCLM, Matrix.mulVec, dotProduct,
    Finset.sum_add_distrib, add_comm]
  rfl

end
end Qrnn
