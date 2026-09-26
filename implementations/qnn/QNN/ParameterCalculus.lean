import QNN.Calculus
import QNN.Activation
import QNN.Training
import Mathlib.Tactic.Abel

/-!
# A connection's weight gradient

The background contains all other incoming weighted signals and the subtractive
threshold. This gives a concrete weight-gradient rule for a neuron and an arbitrary
differentiated downstream objective, rather than a quaternion derivative convention.
-/
noncomputable section
namespace QNN
open ContinuousLinearMap

def pureWeightDerivative (w : H) (x : Pure) : H →L[ℝ] Pure :=
  pureProjection.toContinuousLinearMap.comp (weightDerivative w x)

theorem pureWeight_hasFDerivAt (w : H) (x : Pure) (hw : w ≠ 0) :
    HasFDerivAt (fun a : H => weightAction a x) (pureWeightDerivative w x) w := by
  have hd := pureProjection.toContinuousLinearMap.hasFDerivAt.comp w
    (weightAction_hasFDerivAt w x hw)
  change HasFDerivAt (fun a => pureProjection (weightActionRaw a x))
    (pureWeightDerivative w x) w at hd
  simpa only [weightActionRaw_pure, pureProjection_pure] using hd

/-- Forward computation with a selected weight exposed as the variable. -/
def connectionNeuron (w : H) (x background : Pure) : Pure :=
  activation (weightAction w x + background)

def connectionDerivative (w : H) (x background : Pure) : H →L[ℝ] Pure :=
  (activationDerivative (weightAction w x + background)).comp (pureWeightDerivative w x)

theorem connection_hasFDerivAt (w : H) (x background : Pure) (hw : w ≠ 0) :
    HasFDerivAt (fun a => connectionNeuron a x background)
      (connectionDerivative w x background) w :=
  (activation_hasFDerivAt _).comp w ((pureWeight_hasFDerivAt w x hw).add_const background)

/-- The fixed background for one selected incoming connection. -/
def connectionBackground {ι : Type*} [Fintype ι] [DecidableEq ι]
    (w : ι → H) (θ : Pure) (x : ι → Pure) (i : ι) : Pure :=
  (∑ j ∈ Finset.univ.erase i, weightAction (w j) (x j)) - θ

/-- Isolating a connection does not change the finite neuron computation. -/
theorem neuron_eq_connection {ι : Type*} [Fintype ι] [DecidableEq ι]
    (w : ι → H) (θ : Pure) (x : ι → Pure) (i : ι) :
    neuron w θ x = connectionNeuron (w i) (x i) (connectionBackground w θ x i) := by
  unfold neuron connectionNeuron preactivation connectionBackground
  congr 1
  rw [← Finset.sum_erase_add Finset.univ (fun j => weightAction (w j) (x j))
    (Finset.mem_univ i)]
  abel

/-- The actual neuron gradient for the displayed one-output loss. -/
theorem connection_loss_gradient (w : H) (x background target : Pure) (hw : w ≠ 0) :
    HasGradientAt (fun a => loss (connectionNeuron a x background) target)
      ((connectionDerivative w x background).adjoint
        (connectionNeuron w x background - target)) w :=
  output_loss_chain (connection_hasFDerivAt w x background hw) target

/-- Weight backpropagation when the downstream output cotangent has been justified. -/
theorem connection_backprop (w : H) (x background : Pure) (hw : w ≠ 0)
    {E : Pure → ℝ} {δ : Pure} (hE : HasGradientAt E δ (connectionNeuron w x background)) :
    HasGradientAt (fun a => E (connectionNeuron a x background))
      ((connectionDerivative w x background).adjoint δ) w :=
  gradient_chain (f := fun a => connectionNeuron a x background) (g := E)
    (connection_hasFDerivAt w x background hw) hE

/-- The connection gradient yields exactly the paper's four real partial updates. -/
theorem connection_update_components (w : H) (x background target : Pure)
    (hw : w ≠ 0) (η : ℝ) (i : Fin 4) :
    component (gradientStep η w ((connectionDerivative w x background).adjoint
      (connectionNeuron w x background - target))) i =
      component w i - η * componentPartial
        (fun a => loss (connectionNeuron a x background) target) w i :=
  quaternion_update_eq_partials (connection_loss_gradient w x background target hw) η i
end QNN
