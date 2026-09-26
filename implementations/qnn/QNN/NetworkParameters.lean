import QNN.LayerParameters

/-!
# Network-wide weight backpropagation

A weight address selects a real quaternion parameter in any layer. Replacement
keeps every other parameter fixed. Differentiating that actual modified network
justifies the recursive reverse pass, including all hidden-layer weight gradients.
-/
noncomputable section
namespace QNN
open ContinuousLinearMap
namespace Network

theorem append_euclideanForward {m k n : ℕ} (N : Network m k)
    (L : Layer (Fin k) (Fin n)) (x : Signal m) :
    (N.append L).euclideanForward x = L.euclideanForward (N.euclideanForward x) := by
  simp only [euclideanForward, Layer.euclideanForward, forward]
  rw [ContinuousLinearEquiv.apply_symm_apply]

/-- An address ranges over every weight in every layer of a finite network. -/
inductive WeightIndex : {m n : ℕ} → Network m n → Type
  | single {m n : ℕ} (L : Layer (Fin m) (Fin n)) (j : Fin n) (i : Fin m) :
      WeightIndex (.single L)
  | last {m k n : ℕ} (N : Network m k) (L : Layer (Fin k) (Fin n))
      (j : Fin n) (i : Fin k) : WeightIndex (.append N L)
  | earlier {m k n : ℕ} (N : Network m k) (L : Layer (Fin k) (Fin n))
      (e : WeightIndex N) : WeightIndex (.append N L)

namespace WeightIndex

def value {m n : ℕ} {N : Network m n} : WeightIndex N → H
  | .single L j i => L.weights j i
  | .last _ L j i => L.weights j i
  | .earlier _ _ e => e.value

def replace {m n : ℕ} {N : Network m n} : WeightIndex N → H → Network m n
  | .single L j i, a => .single (L.withWeight j i a)
  | .last N L j i, a => .append N (L.withWeight j i a)
  | .earlier _ L e, a => .append (e.replace a) L

@[simp] theorem replace_self {m n : ℕ} {N : Network m n} (e : WeightIndex N) :
    e.replace e.value = N := by
  induction e with
  | single L j i => simp [replace, value]
  | last N L j i => simp [replace, value]
  | earlier N L e ih => simp [replace, value, ih]

/-- Forward sensitivity to this actual weight, including all downstream layers. -/
def derivative {m n : ℕ} {N : Network m n} : WeightIndex N → Signal m → (H →L[ℝ] Signal n)
  | .single L j i, x => L.euclideanWeightDerivative x j i
  | .last N L j i, x => L.euclideanWeightDerivative (N.euclideanForward x) j i
  | .earlier N L e, x => (L.euclideanInputDerivative (N.euclideanForward x)).comp (e.derivative x)

theorem hasFDerivAt {m n : ℕ} {N : Network m n} (e : WeightIndex N)
    (x : Signal m) (hw : e.value ≠ 0) :
    HasFDerivAt (fun a => (e.replace a).euclideanForward x) (e.derivative x) e.value := by
  induction e with
  | single L j i => exact L.euclideanWeight_hasFDerivAt x j i hw
  | last N L j i =>
    simpa only [replace, value, derivative, append_euclideanForward] using
      L.euclideanWeight_hasFDerivAt (N.euclideanForward x) j i hw
  | earlier N L e ih =>
    have hd := (L.euclideanInput_hasFDerivAt ((e.replace e.value).euclideanForward x)).comp e.value (ih hw)
    simpa only [replace, derivative, value, replace_self, append_euclideanForward] using! hd

/-- Reverse recursion uses original forward signals and propagates output cotangents. -/
def backprop {m n : ℕ} {N : Network m n} : WeightIndex N → Signal m → Signal n → H
  | .single L j i, x, δ => (L.euclideanWeightDerivative x j i).adjoint δ
  | .last N L j i, x, δ => (L.euclideanWeightDerivative (N.euclideanForward x) j i).adjoint δ
  | .earlier N L e, x, δ => e.backprop x ((L.euclideanInputDerivative (N.euclideanForward x)).adjoint δ)

theorem backprop_eq {m n : ℕ} {N : Network m n} (e : WeightIndex N)
    (x : Signal m) (δ : Signal n) : e.backprop x δ = (e.derivative x).adjoint δ := by
  induction e with
  | single L j i => rfl
  | last N L j i => rfl
  | earlier N L e ih =>
    rw [backprop, derivative, adjoint_comp, comp_apply, ih]

/-- Every hidden or output weight receives the true real gradient of the objective. -/
theorem backprop_hasGradientAt {m n : ℕ} {N : Network m n} (e : WeightIndex N)
    (x : Signal m) (hw : e.value ≠ 0) {E : Signal n → ℝ} {δ : Signal n}
    (hE : HasGradientAt E δ (N.euclideanForward x)) :
    HasGradientAt (fun a => E ((e.replace a).euclideanForward x)) (e.backprop x δ) e.value := by
  rw [backprop_eq]
  apply gradient_chain (f := fun a => (e.replace a).euclideanForward x) (g := E)
    (e.hasFDerivAt x hw)
  simpa only [replace_self] using hE

/-- Four component updates for an arbitrary weight in an arbitrary layer. -/
theorem update_components {m n : ℕ} {N : Network m n} (e : WeightIndex N)
    (x : Signal m) (hw : e.value ≠ 0) {E : Signal n → ℝ} {δ : Signal n}
    (hE : HasGradientAt E δ (N.euclideanForward x)) (η : ℝ) (c : Fin 4) :
    component (gradientStep η e.value (e.backprop x δ)) c = component e.value c -
      η * componentPartial (fun a => E ((e.replace a).euclideanForward x)) e.value c :=
  quaternion_update_eq_partials (e.backprop_hasGradientAt x hw hE) η c
end WeightIndex
end Network
end QNN
