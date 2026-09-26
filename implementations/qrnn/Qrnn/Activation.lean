import Qrnn.ActivationCore
import Mathlib.Analysis.Calculus.FDeriv.Pi
import Mathlib.Analysis.Calculus.FDeriv.Equiv
import Mathlib.Analysis.Calculus.Deriv.Basic

/-!
# Split activations as ordinary real differentiable maps

The diagonal derivative is valid at coordinates where the scalar activation is
differentiable. No differentiability assertion is made at a ReLU corner.
-/

namespace Qrnn

-- The generalized calculus API uses additive/module instances independently of
-- the topology. Select the instances used by mathlib's quaternion isometry.
@[reducible] noncomputable def calculusAddCommGroup : AddCommGroup Q :=
  Quaternion.instNormedAddCommGroupReal.toAddCommGroup
@[reducible] noncomputable def calculusModule : Module ℝ Q :=
  Quaternion.instInnerProductSpaceReal.toModule

attribute [local instance] calculusAddCommGroup calculusModule

noncomputable section

/-- The quaternion coordinate equivalence with the finite product norm. -/
def coordinateEquiv : Q ≃L[ℝ] (Fin 4 → ℝ) :=
  Quaternion.linearIsometryEquivTuple.toContinuousLinearEquiv.trans
    (PiLp.continuousLinearEquiv 2 ℝ (fun _ : Fin 4 => ℝ))

@[simp] theorem coordinateEquiv_apply (q : Q) : coordinateEquiv q = components q := rfl
@[simp] theorem coordinateEquiv_symm_apply (v : Fin 4 → ℝ) :
    coordinateEquiv.symm v = ofComponents v := rfl

/-- The four diagonal derivative coefficients. -/
def diagonalCLM (d : Fin 4 → ℝ) : (Fin 4 → ℝ) →L[ℝ] (Fin 4 → ℝ) :=
  ContinuousLinearMap.pi (fun a => d a • ContinuousLinearMap.proj a)

@[simp] theorem diagonalCLM_apply (d v : Fin 4 → ℝ) (a : Fin 4) :
    diagonalCLM d v a = d a * v a := rfl

theorem splitReal_hasFDerivAt (f : ℝ → ℝ) (v d : Fin 4 → ℝ)
    (hf : ∀ a, HasDerivAt f (d a) (v a)) :
    HasFDerivAt (splitReal f) (diagonalCLM d) v := by
  apply hasFDerivAt_pi.mpr
  intro a
  convert (hf a).hasFDerivAt.comp v (hasFDerivAt_apply (𝕜 := ℝ) a v) using 1 <;>
    ext w <;> simp [splitReal, mul_comm]

/-- The derivative transported back to quaternions; a continuous ℝ-linear map. -/
def splitDerivative (d : Fin 4 → ℝ) : Q →L[ℝ] Q :=
  coordinateEquiv.symm.toContinuousLinearMap.comp
    ((diagonalCLM d).comp coordinateEquiv.toContinuousLinearMap)

@[simp] theorem components_splitDerivative (d : Fin 4 → ℝ) (h : Q) :
    components (splitDerivative d h) = fun a => d a * components h a := by
  ext a
  simp [splitDerivative, diagonalCLM]

/-- Full real Fréchet derivative, with scalar hypotheses at preactivation coordinates. -/
theorem splitActivation_hasFDerivAt (f : ℝ → ℝ) (q : Q) (d : Fin 4 → ℝ)
    (hf : ∀ a, HasDerivAt f (d a) (components q a)) :
    HasFDerivAt (splitActivation f) (splitDerivative d) q := by
  change HasFDerivAt (coordinateEquiv.symm ∘ splitReal f ∘ coordinateEquiv)
    (coordinateEquiv.symm.toContinuousLinearMap.comp
      ((diagonalCLM d).comp coordinateEquiv.toContinuousLinearMap)) q
  exact coordinateEquiv.symm.hasFDerivAt.comp q
    ((splitReal_hasFDerivAt f (coordinateEquiv q) d hf).comp q coordinateEquiv.hasFDerivAt)

/-- A split derivative is self-adjoint under the Euclidean real pairing. -/
theorem splitDerivative_pair (d : Fin 4 → ℝ) (h g : Q) :
    realPair (splitDerivative d h) g = realPair h (splitDerivative d g) := by
  simp only [realPair, components_splitDerivative]
  apply Finset.sum_congr rfl
  intro a _
  ring

/-- Diagonal derivative action is a Hadamard product, not a Hamilton product. -/
theorem splitDerivative_eq_hadamard (d : Fin 4 → ℝ) (h : Q) :
    splitDerivative d h = hadamard (ofComponents d) h := by
  apply components_injective
  simp


end
end Qrnn
