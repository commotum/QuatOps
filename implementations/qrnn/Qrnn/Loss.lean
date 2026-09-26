import Qrnn.Derivatives

/-!
# Half squared Euclidean loss and local real gradients

The `1/2` convention is explicit. Residual-only weight updates require an identity
output activation (or a separate justified activation/loss cancellation).
-/

namespace Qrnn
attribute [local instance] calculusAddCommGroup calculusModule
noncomputable section

/-- Half squared error on arbitrary finite real coordinates. -/
def realSquaredLoss {ι : Type*} [Fintype ι] (y p : ι → ℝ) : ℝ :=
  ∑ i, (1 / 2 : ℝ) * ((p i - y i) * (p i - y i))

/-- Euclidean residual as the real differential functional. -/
def realLossDerivative {ι : Type*} [Fintype ι] (y p : ι → ℝ) : (ι → ℝ) →L[ℝ] ℝ :=
  ∑ i, (p i - y i) • ContinuousLinearMap.proj i

@[simp] theorem realLossDerivative_apply {ι : Type*} [Fintype ι]
    (y p v : ι → ℝ) : realLossDerivative y p v = ∑ i, (p i - y i) * v i := by
  simp [realLossDerivative]

theorem realSquaredLoss_hasFDerivAt {ι : Type*} [Fintype ι] (y p : ι → ℝ) :
    HasFDerivAt (realSquaredLoss y) (realLossDerivative y p) p := by
  classical
  apply HasFDerivAt.fun_sum
  intro i _
  have hh := (hasFDerivAt_apply (𝕜 := ℝ) i p).sub_const (y i)
  convert (hh.mul hh).const_mul (1 / 2 : ℝ) using 1
  ext v
  simp
  ring

/-- Continuous coordinate map for all neurons, in neuron-major indexing. -/
def vectorComponentsCLM {n : ℕ} : QVector n →L[ℝ] (Fin n × Fin 4 → ℝ) :=
  ContinuousLinearMap.pi (fun i =>
    (ContinuousLinearMap.proj i.2 : (Fin 4 → ℝ) →L[ℝ] ℝ).comp
      (coordinateEquiv.toContinuousLinearMap.comp (ContinuousLinearMap.proj i.1)))

@[simp] theorem vectorComponentsCLM_apply {n : ℕ} (v : QVector n) :
    vectorComponentsCLM v = vectorComponents v := rfl

/-- Real-valued loss on quaternion vectors, with no quaternion derivative convention. -/
def halfSquaredLoss {n : ℕ} (y p : QVector n) : ℝ :=
  realSquaredLoss (vectorComponents y) (vectorComponents p)

def lossDerivative {n : ℕ} (y p : QVector n) : QVector n →L[ℝ] ℝ :=
  (realLossDerivative (vectorComponents y) (vectorComponents p)).comp vectorComponentsCLM

theorem halfSquaredLoss_hasFDerivAt {n : ℕ} (y p : QVector n) :
    HasFDerivAt (halfSquaredLoss y) (lossDerivative y p) p := by
  have hcoord : (fun v : QVector n => vectorComponentsCLM v) = vectorComponents := rfl
  have hc : HasFDerivAt vectorComponents (vectorComponentsCLM (n := n)) p := by
    rw [← hcoord]
    exact vectorComponentsCLM.hasFDerivAt
  exact (realSquaredLoss_hasFDerivAt (vectorComponents y) (vectorComponents p)).comp p hc

/-- The differential really is the Euclidean pairing with the residual. -/
theorem lossDerivative_pair {n : ℕ} (y p v : QVector n) :
    lossDerivative y p v = vectorPair v (p-y) := by
  simp only [lossDerivative, ContinuousLinearMap.comp_apply, realLossDerivative_apply,
    vectorComponentsCLM_apply, Fintype.sum_prod_type, vectorPair, realPair, vectorComponents]
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro a _
  fin_cases a <;> simp [components, Quaternion.equivTuple_apply, mul_comm]

/-- One-layer output-loss real derivative, including the split activation factor. -/
theorem outputLoss_hasFDerivAt {h o : ℕ} (W : QMatrix o h) (β : ℝ → ℝ)
    (s : QVector h) (y : QVector o) (dβ : Fin o → Fin 4 → ℝ)
    (hβ : ∀ i a, HasDerivAt β (dβ i a) (components (W.mulVec s i) a)) :
    HasFDerivAt (fun A : QMatrix o h => halfSquaredLoss y (vectorActivation β (A.mulVec s)))
      ((lossDerivative y (vectorActivation β (W.mulVec s))).comp
        ((vectorSplitDerivative dβ).comp (weightActionCLM s))) W :=
  (halfSquaredLoss_hasFDerivAt y (vectorActivation β (W.mulVec s))).comp W
    (layerWeight_hasFDerivAt W β s dβ hβ)

/-- Correct output-weight gradient in four-component real coordinates. -/
theorem output_gradient {h o : ℕ} (W : QMatrix o h) (β : ℝ → ℝ)
    (s : QVector h) (y : QVector o) (dβ : Fin o → Fin 4 → ℝ)
    (dW : QMatrix o h) :
    ((lossDerivative y (vectorActivation β (W.mulVec s))).comp
      ((vectorSplitDerivative dβ).comp (weightActionCLM s))) dW =
    matrixPair dW (weightOuter
      (vectorSplitDerivative dβ (vectorActivation β (W.mulVec s) - y)) s) := by
  simp only [ContinuousLinearMap.comp_apply, lossDerivative_pair, weightActionCLM_apply]
  exact output_weight_pair dβ dW s (vectorActivation β (W.mulVec s) - y)

end
end Qrnn
