import QNN.Model
import Mathlib.Analysis.Calculus.FDeriv.Prod

/-! The activation Jacobian is diagonal in the fixed imaginary coordinate frame. -/
noncomputable section
namespace QNN
open ContinuousLinearMap

def coordinate (i : Fin 3) : Pure →L[ℝ] ℝ :=
  (ContinuousLinearMap.proj i).comp pureCoordinates.toContinuousLinearEquiv.toContinuousLinearMap

@[simp] theorem coordinate_apply (i : Fin 3) (s : Pure) : coordinate i s = vector s i := rfl

/-- The real sigmoid slope at each imaginary component. -/
def activationSlope (s : Pure) (i : Fin 3) : ℝ :=
  Real.sigmoid (vector s i) * (1 - Real.sigmoid (vector s i))

def activationDerivative (s : Pure) : Pure →L[ℝ] Pure :=
  pureCoordinates.symm.toContinuousLinearEquiv.toContinuousLinearMap.comp
    (ContinuousLinearMap.pi (fun i => activationSlope s i • coordinate i))

@[simp] theorem activationDerivative_coordinate (s h : Pure) (i : Fin 3) :
    vector (activationDerivative s h) i = activationSlope s i * vector h i := by
  change pureCoordinates (pureCoordinates.symm _) i = _
  rw [pureCoordinates.apply_symm_apply]
  rfl

theorem activation_hasFDerivAt (s : Pure) :
    HasFDerivAt activation (activationDerivative s) s := by
  have h : HasFDerivAt (fun t : Pure => fun i : Fin 3 => Real.sigmoid (vector t i))
      (ContinuousLinearMap.pi (fun i => activationSlope s i • coordinate i)) s := by
    apply hasFDerivAt_pi.mpr
    intro i
    have hi := (Real.hasDerivAt_sigmoid (vector s i)).comp_hasFDerivAt s
      ((coordinate i).hasFDerivAt (x := s))
    simpa only [coordinate_apply, activationSlope] using! hi
  exact pureCoordinates.symm.toContinuousLinearEquiv.toContinuousLinearMap.hasFDerivAt.comp s h

theorem activation_differentiable : Differentiable ℝ activation :=
  fun s => (activation_hasFDerivAt s).differentiableAt
end QNN
