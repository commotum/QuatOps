import QNN.ParameterCalculus

/-! Replacing one actual layer weight and differentiating the resulting forward map. -/
noncomputable section
namespace QNN
open ContinuousLinearMap

theorem neuron_update_eq_connection {ι : Type*} [Fintype ι] [DecidableEq ι]
    (w : ι → H) (θ : Pure) (x : ι → Pure) (i : ι) (a : H) :
    neuron (Function.update w i a) θ x =
      connectionNeuron a (x i) (connectionBackground w θ x i) := by
  rw [neuron_eq_connection _ θ x i]
  congr 1
  · simp
  · unfold connectionBackground
    congr 1
    apply Finset.sum_congr rfl
    intro j hj
    rw [Function.update_of_ne (Finset.ne_of_mem_erase hj)]

namespace Layer

/-- Change one connection; thresholds and other connections retain their values. -/
def withWeight {ι ο : Type*} [DecidableEq ι] [DecidableEq ο]
    (L : Layer ι ο) (j : ο) (i : ι) (a : H) : Layer ι ο where
  weights := Function.update L.weights j (Function.update (L.weights j) i a)
  thresholds := L.thresholds

@[simp] theorem withWeight_self {ι ο : Type*} [DecidableEq ι] [DecidableEq ο]
    (L : Layer ι ο) (j : ο) (i : ι) : L.withWeight j i (L.weights j i) = L := by
  cases L
  simp [withWeight]

/-- The selected weight influences only its target neuron in this layer. -/
def weightDerivative {ι ο : Type*} [Fintype ι] [Fintype ο]
    [DecidableEq ι] [DecidableEq ο] (L : Layer ι ο) (x : ι → Pure) (j : ο) (i : ι) :
    H →L[ℝ] (ο → Pure) :=
  ContinuousLinearMap.pi (fun k => if k = j then
    connectionDerivative (L.weights j i) (x i)
      (connectionBackground (L.weights j) (L.thresholds j) x i) else 0)

theorem weight_hasFDerivAt {ι ο : Type*} [Fintype ι] [Fintype ο]
    [DecidableEq ι] [DecidableEq ο] (L : Layer ι ο) (x : ι → Pure) (j : ο) (i : ι)
    (hw : L.weights j i ≠ 0) :
    HasFDerivAt (fun a => (L.withWeight j i a).forward x)
      (L.weightDerivative x j i) (L.weights j i) := by
  apply hasFDerivAt_pi.mpr
  intro k
  by_cases hk : k = j
  · subst k
    simpa only [withWeight, forward, Function.update_self, if_true,
      neuron_update_eq_connection] using
      connection_hasFDerivAt (L.weights j i) (x i)
        (connectionBackground (L.weights j) (L.thresholds j) x i) hw
  · simpa only [withWeight, forward, Function.update_of_ne hk, if_neg hk] using
      (hasFDerivAt_const (neuron (L.weights k) (L.thresholds k) x) (L.weights j i))

/-- Euclidean version of the actual finite-layer forward map. -/
def euclideanForward {m n : ℕ} (L : Layer (Fin m) (Fin n)) : Signal m → Signal n :=
  (Network.single L).euclideanForward

def euclideanInputDerivative {m n : ℕ} (L : Layer (Fin m) (Fin n)) (x : Signal m) :
    Signal m →L[ℝ] Signal n := (Network.single L).euclideanInputDerivative x

theorem euclideanInput_hasFDerivAt {m n : ℕ} (L : Layer (Fin m) (Fin n)) (x : Signal m) :
    HasFDerivAt L.euclideanForward (L.euclideanInputDerivative x) x :=
  (Network.single L).euclideanInput_hasFDerivAt x

def euclideanWeightDerivative {m n : ℕ} (L : Layer (Fin m) (Fin n))
    (x : Signal m) (j : Fin n) (i : Fin m) : H →L[ℝ] Signal n :=
  (signalCoordinates n).symm.toContinuousLinearMap.comp
    (L.weightDerivative (signalCoordinates m x) j i)

theorem euclideanWeight_hasFDerivAt {m n : ℕ} (L : Layer (Fin m) (Fin n))
    (x : Signal m) (j : Fin n) (i : Fin m) (hw : L.weights j i ≠ 0) :
    HasFDerivAt (fun a => (L.withWeight j i a).euclideanForward x)
      (L.euclideanWeightDerivative x j i) (L.weights j i) :=
  (signalCoordinates n).symm.toContinuousLinearMap.hasFDerivAt.comp _
    (L.weight_hasFDerivAt (signalCoordinates m x) j i hw)
end Layer
end QNN
