import QNN.Training

/-! Real Jacobians for complete finite forward networks, with fixed parameters. -/
noncomputable section
namespace QNN
open ContinuousLinearMap

/-- A fixed neuron's input Jacobian includes the component sigmoid slopes. -/
def neuronInputDerivative {ι : Type*} [Fintype ι]
    (w : ι → H) (θ : Pure) (x : ι → Pure) : (ι → Pure) →L[ℝ] Pure :=
  (activationDerivative (preactivation w θ x)).comp (inputLinear w).toContinuousLinearMap

theorem neuronInput_hasFDerivAt {ι : Type*} [Fintype ι]
    (w : ι → H) (θ : Pure) (x : ι → Pure) :
    HasFDerivAt (neuron w θ) (neuronInputDerivative w θ x) x :=
  (activation_hasFDerivAt _).comp x ((inputLinear w).toContinuousLinearMap.hasFDerivAt.sub_const θ)

namespace Layer

def inputDerivative {ι ο : Type*} [Fintype ι] [Fintype ο]
    (L : Layer ι ο) (x : ι → Pure) : (ι → Pure) →L[ℝ] (ο → Pure) :=
  ContinuousLinearMap.pi (fun j => neuronInputDerivative (L.weights j) (L.thresholds j) x)

theorem input_hasFDerivAt {ι ο : Type*} [Fintype ι] [Fintype ο]
    (L : Layer ι ο) (x : ι → Pure) :
    HasFDerivAt L.forward (L.inputDerivative x) x :=
  hasFDerivAt_pi.mpr (fun j => neuronInput_hasFDerivAt (L.weights j) (L.thresholds j) x)
end Layer

namespace Network

def inputDerivative {m n : ℕ} : (N : Network m n) →
    (x : Fin m → Pure) → ((Fin m → Pure) →L[ℝ] (Fin n → Pure))
  | .single L, x => L.inputDerivative x
  | .append N L, x => (L.inputDerivative (N.forward x)).comp (N.inputDerivative x)

theorem input_hasFDerivAt {m n : ℕ} (N : Network m n) (x : Fin m → Pure) :
    HasFDerivAt N.forward (N.inputDerivative x) x := by
  induction N with
  | single L => exact L.input_hasFDerivAt x
  | append N L ih => exact (L.input_hasFDerivAt _).comp x ih
/-- Reverse-mode derivative recursion, expressed in dual spaces to avoid confusing
    the raw function norm with the Euclidean gradient metric. -/
def pullback {m n : ℕ} : (N : Network m n) → (x : Fin m → Pure) →
    StrongDual ℝ (Fin n → Pure) → StrongDual ℝ (Fin m → Pure)
  | .single L, x, δ => δ.comp (L.inputDerivative x)
  | .append N L, x, δ => N.pullback x (δ.comp (L.inputDerivative (N.forward x)))

/-- The recursive reverse pass is exactly the dual of the forward Jacobian. -/
theorem pullback_eq {m n : ℕ} (N : Network m n) (x : Fin m → Pure)
    (δ : StrongDual ℝ (Fin n → Pure)) :
    N.pullback x δ = δ.comp (N.inputDerivative x) := by
  induction N generalizing δ with
  | single L => rfl
  | append N L ih =>
    rw [pullback, inputDerivative, ih]
    rfl

/-- A justified output differential is propagated correctly through every hidden layer. -/
theorem pullback_hasFDerivAt {m n : ℕ} (N : Network m n) (x : Fin m → Pure)
    {E : (Fin n → Pure) → ℝ} {δ : StrongDual ℝ (Fin n → Pure)}
    (hE : HasFDerivAt E δ (N.forward x)) :
    HasFDerivAt (fun z => E (N.forward z)) (N.pullback x δ) x := by
  rw [pullback_eq]
  exact hE.comp x (N.input_hasFDerivAt x)
end Network

/-- Euclidean finite-layer signal space; raw function-space norms are not used for gradients. -/
abbrev Signal (n : ℕ) := PiLp 2 (fun _ : Fin n => Pure)

/-- Coordinate conversion preserves linear structure; it changes the raw supremum norm. -/
def signalCoordinates (n : ℕ) : Signal n ≃L[ℝ] (Fin n → Pure) :=
  (WithLp.linearEquiv 2 ℝ (Fin n → Pure)).toContinuousLinearEquiv

namespace Network

def euclideanForward {m n : ℕ} (N : Network m n) (x : Signal m) : Signal n :=
  (signalCoordinates n).symm (N.forward (signalCoordinates m x))

def euclideanInputDerivative {m n : ℕ} (N : Network m n) (x : Signal m) :
    Signal m →L[ℝ] Signal n :=
  (signalCoordinates n).symm.toContinuousLinearMap.comp
    ((N.inputDerivative (signalCoordinates m x)).comp (signalCoordinates m).toContinuousLinearMap)

theorem euclideanInput_hasFDerivAt {m n : ℕ} (N : Network m n) (x : Signal m) :
    HasFDerivAt N.euclideanForward (N.euclideanInputDerivative x) x :=
  (signalCoordinates n).symm.toContinuousLinearMap.hasFDerivAt.comp x
    ((N.input_hasFDerivAt _).comp x (signalCoordinates m).toContinuousLinearMap.hasFDerivAt)

/-- Reverse propagation through the full specified forward model. -/
theorem input_gradient_chain {m n : ℕ} (N : Network m n) (x : Signal m)
    {E : Signal n → ℝ} {δ : Signal n} (hE : HasGradientAt E δ (N.euclideanForward x)) :
    HasGradientAt (fun z => E (N.euclideanForward z))
      ((N.euclideanInputDerivative x).adjoint δ) x :=
  gradient_chain (N.euclideanInput_hasFDerivAt x) hE
end Network
end QNN
