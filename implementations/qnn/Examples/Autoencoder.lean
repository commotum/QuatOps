import QNN.Backpropagation

/-!
An exact finite-network example showing how to address a hidden weight and apply
the proved update rule. The dimensions match the reported 16-4-16 architecture;
these all-one weights are illustrative, not recovered experimental weights.
-/
noncomputable section
namespace QNN.Examples

def allOneLayer (m n : ℕ) : Layer (Fin m) (Fin n) where
  weights := fun _ _ => 1
  thresholds := fun _ => 0

theorem allOneLayer_admissible (m n : ℕ) : (allOneLayer m n).Admissible := by
  intro j i
  exact one_ne_zero

def autoencoder : Network 16 16 :=
  (Network.single (allOneLayer 16 4)).append (allOneLayer 4 16)

theorem autoencoder_admissible : autoencoder.Admissible :=
  ⟨allOneLayer_admissible 16 4, allOneLayer_admissible 4 16⟩

/-- A first-layer weight, which requires backward propagation through the output layer. -/
def hiddenWeight : Network.WeightIndex autoencoder :=
  .earlier (.single (allOneLayer 16 4)) (allOneLayer 4 16) (.single (allOneLayer 16 4) 0 0)

/-- Instantiate the network-wide theorem on a genuine hidden-layer parameter. -/
theorem hidden_update (η : ℝ) (x d : Signal 16) (c : Fin 4) :
    component (autoencoder.updatedIndex η x d hiddenWeight).value c =
      component hiddenWeight.value c - η * componentPartial
        (fun a => (hiddenWeight.replace a).objective x d) hiddenWeight.value c :=
  autoencoder.trainStep_components η x d autoencoder_admissible hiddenWeight c
end QNN.Examples
