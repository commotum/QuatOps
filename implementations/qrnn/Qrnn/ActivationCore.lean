import Qrnn.Algebra

/-!
# Componentwise activation definitions

This public definition layer has no calculus imports. Derivative constructions
and proofs live in `Qrnn.Activation`, so forward architectures do not depend on
changes to those proofs.
-/

namespace Qrnn
noncomputable section

/-- Scalar activation applied to each real quaternion component. -/
def splitActivation (f : ℝ → ℝ) (q : Q) : Q :=
  ofComponents (fun a => f (components q a))

@[simp] theorem components_splitActivation (f : ℝ → ℝ) (q : Q) :
    components (splitActivation f q) = fun a => f (components q a) :=
  components_ofComponents _

/-- The corresponding real map in coordinates. -/
def splitReal (f : ℝ → ℝ) (v : Fin 4 → ℝ) : Fin 4 → ℝ := fun a => f (v a)

/-- Split activation of every quaternion neuron. -/
def vectorActivation {n : ℕ} (f : ℝ → ℝ) (v : QVector n) : QVector n :=
  fun i => splitActivation f (v i)


end
end Qrnn
