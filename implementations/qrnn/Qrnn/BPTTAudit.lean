import Qrnn.QRNNGradients

/-!
# Diagnostic counterexample to products of propagated error vectors

In a two-step one-neuron real subcase, the two preactivation cotangents are 2
and 2. Correct shared-bias accumulation is 4; the literal compact expression
δ₀*δ₁ + δ₁ is 6. Jacobian products are legitimate, but these propagated errors
are already cotangents. The diagnostic is not imported by the public API.
-/

namespace Qrnn
open scoped Matrix.Norms.Elementwise
attribute [local instance] calculusAddCommGroup calculusModule
noncomputable section

private def linearExampleParams : QRNNParams 1 1 1 :=
  ⟨fun _ _ => 1, 0, fun _ _ => 1, fun _ => 1⟩

private theorem splitOne {n : ℕ} (v : QVector n) :
    vectorSplitDerivative (fun _ _ => 1) v = v := by
  funext i
  apply components_injective
  simp only [vectorSplitDerivative_apply, components_splitDerivative, one_mul]

/-- The compact paper formula, when products denote Hamilton products of the
already propagated errors, disagrees even in a real linear subcase. -/
theorem propagated_error_product_counterexample :
    components ((quaternionBpttGradient linearExampleParams id (fun _ => 0) 0
      (fun _ _ _ => 1) 2 (fun _ => 2)).2.2.2 0) 0 = 4 ∧
      (2 : ℝ) * 2 + 2 ≠ 4 := by
  constructor
  · norm_num [quaternionBpttGradient, stepParameterGradient, splitOne, linearExampleParams,
      Matrix.mulVec, dotProduct, components, Quaternion.equivTuple_apply]
    rfl
  · norm_num

end
end Qrnn
