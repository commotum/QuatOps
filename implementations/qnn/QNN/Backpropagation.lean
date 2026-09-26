import QNN.NetworkParameters

/-!
# Squared-output-error training

The finite-output sum is an explicit extension of the paper's displayed
single-output loss. Gradients are proved for all weight addresses, including
hidden layers, and can be applied simultaneously from the original network.
No step-size, loss-decrease, convergence or admissibility-preservation result is claimed.
-/
noncomputable section
namespace QNN
open ContinuousLinearMap

/-- Half squared Euclidean error across the entire output layer. -/
def signalLoss {n : ℕ} (y d : Signal n) : ℝ := (1 / 2 : ℝ) * ‖y - d‖ ^ 2

theorem signalLoss_eq_outputLoss {n : ℕ} (y d : Signal n) :
    signalLoss y d = outputLoss (signalCoordinates n y) (signalCoordinates n d) := by
  unfold signalLoss outputLoss loss
  rw [PiLp.norm_sq_eq_of_L2]
  rw [Finset.mul_sum]
  rfl

theorem signalLoss_hasGradientAt {n : ℕ} (y d : Signal n) :
    HasGradientAt (fun z => signalLoss z d) (y - d) y := by
  rw [hasGradientAt_iff_hasFDerivAt]
  have hd := ((hasFDerivAt_id (𝕜 := ℝ) y).sub_const d).norm_sq
  apply (hd.const_mul (1 / 2 : ℝ)).congr_fderiv
  ext h
  simp [InnerProductSpace.toDual_apply_apply]

namespace Network

def objective {m n : ℕ} (N : Network m n) (x : Signal m) (d : Signal n) : ℝ :=
  signalLoss (N.euclideanForward x) d

/-- Original-network output error seeds the whole backward pass. -/
def weightGradient {m n : ℕ} (N : Network m n) (x : Signal m) (d : Signal n)
    (e : WeightIndex N) : H := e.backprop x (N.euclideanForward x - d)

theorem weightGradient_hasGradientAt {m n : ℕ} (N : Network m n)
    (x : Signal m) (d : Signal n) (e : WeightIndex N) (hw : e.value ≠ 0) :
    HasGradientAt (fun a => (e.replace a).objective x d) (N.weightGradient x d e) e.value :=
  e.backprop_hasGradientAt x hw (signalLoss_hasGradientAt (N.euclideanForward x) d)

theorem weightGradient_component {m n : ℕ} (N : Network m n)
    (x : Signal m) (d : Signal n) (e : WeightIndex N) (hw : e.value ≠ 0) (c : Fin 4) :
    component (N.weightGradient x d e) c =
      componentPartial (fun a => (e.replace a).objective x d) e.value c :=
  (componentPartial_eq_gradient (N.weightGradient_hasGradientAt x d e hw) c).symm

/-- Replace every weight from an indexed parameter assignment, keeping thresholds fixed. -/
def mapWeights {m n : ℕ} : (N : Network m n) → (WeightIndex N → H) → Network m n
  | .single L, f => .single { weights := fun j i => f (.single L j i), thresholds := L.thresholds }
  | .append N L, f => .append (N.mapWeights (fun e => f (.earlier N L e)))
      { weights := fun j i => f (.last N L j i), thresholds := L.thresholds }

namespace WeightIndex

/-- The same architecture address in a network with a new weight assignment. -/
def reindex {m n : ℕ} {N : Network m n} :
    (e : WeightIndex N) → (f : WeightIndex N → H) → WeightIndex (N.mapWeights f)
  | .single L j i, _ => .single _ j i
  | .last _ _ j i, _ => .last _ _ j i
  | .earlier N L e, f => .earlier _ _ (e.reindex (fun a => f (.earlier N L a)))

@[simp] theorem reindex_value {m n : ℕ} {N : Network m n}
    (f : WeightIndex N → H) (e : WeightIndex N) : (e.reindex f).value = f e := by
  induction e with
  | single L j i => rfl
  | last N L j i => rfl
  | earlier N L e ih => exact ih (fun a => f (.earlier N L a))

theorem value_ne_zero_of_admissible {m n : ℕ} {N : Network m n}
    (e : WeightIndex N) (hN : N.Admissible) : e.value ≠ 0 := by
  induction e with
  | single L j i => exact hN j i
  | last N L j i => exact hN.2 j i
  | earlier N L e ih => exact ih hN.1
end WeightIndex

/-- Simultaneous weight updates all use the same original-network loss gradient.
    Thresholds remain fixed because their training is not specified in the paper. -/
def trainStep {m n : ℕ} (η : ℝ) (N : Network m n) (x : Signal m) (d : Signal n) : Network m n :=
  N.mapWeights (fun e => gradientStep η e.value (N.weightGradient x d e))

/-- Read the corresponding weight after the simultaneous update. -/
def updatedIndex {m n : ℕ} (η : ℝ) (N : Network m n) (x : Signal m) (d : Signal n)
    (e : WeightIndex N) : WeightIndex (N.trainStep η x d) :=
  e.reindex (fun a => gradientStep η a.value (N.weightGradient x d a))

/-- The training rule equals the paper's four real-coordinate updates at every layer. -/
theorem trainStep_components {m n : ℕ} (η : ℝ) (N : Network m n)
    (x : Signal m) (d : Signal n) (hN : N.Admissible) (e : WeightIndex N) (c : Fin 4) :
    component (N.updatedIndex η x d e).value c = component e.value c - η *
      componentPartial (fun a => (e.replace a).objective x d) e.value c := by
  change component (e.reindex (fun a => gradientStep η a.value (N.weightGradient x d a))).value c = _
  rw [WeightIndex.reindex_value]
  exact quaternion_update_eq_partials
    (N.weightGradient_hasGradientAt x d e (e.value_ne_zero_of_admissible hN)) η c
end Network
end QNN
