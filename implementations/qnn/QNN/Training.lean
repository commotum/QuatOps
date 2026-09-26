import QNN.Calculus
import QNN.Activation
import Mathlib.Analysis.Calculus.Gradient.Basic
import Mathlib.Analysis.InnerProductSpace.Adjoint

/-!
# Real gradients and reusable reverse differentiation

The adjoint chain rule is the mathematical core of backpropagation. Application
to a particular layer still requires its actual derivative; no hidden-layer
formula is attributed to the paper. Updates alone do not imply loss decrease.
-/
noncomputable section
namespace QNN
open ContinuousLinearMap

section ChainRule
variable {E F : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
  [NormedAddCommGroup F] [InnerProductSpace ℝ F] [CompleteSpace F]

/-- Reverse propagation of a scalar objective through a real differentiable map. -/
theorem gradient_chain {f : E → F} {f' : E →L[ℝ] F} {g : F → ℝ}
    {x : E} {δ : F} (hf : HasFDerivAt f f' x) (hg : HasGradientAt g δ (f x)) :
    HasGradientAt (fun z => g (f z)) (f'.adjoint δ) x := by
  rw [hasGradientAt_iff_hasFDerivAt]
  apply (hg.hasFDerivAt.comp x hf).congr_fderiv
  ext h
  exact (f'.adjoint_inner_left h δ).symm

/-- Parameter update in a real inner-product space, with an explicit gradient. -/
def gradientStep (η : ℝ) (p grad : E) : E := p - η • grad

end ChainRule

/-- Gradient of the source's one-output squared error. -/
theorem loss_hasGradientAt (y d : Pure) : HasGradientAt (fun z => loss z d) (y - d) y := by
  rw [hasGradientAt_iff_hasFDerivAt]
  have hd := ((hasFDerivAt_id (𝕜 := ℝ) y).sub_const d).norm_sq
  apply (hd.const_mul (1 / 2 : ℝ)).congr_fderiv
  ext h
  simp [InnerProductSpace.toDual_apply_apply]

/-- Backpropagation from one output loss through any proved real derivative. -/
theorem output_loss_chain {E : Type*} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] [CompleteSpace E] {f : E → Pure}
    {f' : E →L[ℝ] Pure} {p : E} (hf : HasFDerivAt f f' p) (d : Pure) :
    HasGradientAt (fun q => loss (f q) d) (f'.adjoint (f p - d)) p :=
  gradient_chain (f := f) (g := fun y => loss y d) hf (loss_hasGradientAt (f p) d)

/-- Four real quaternion coordinates, ordered e,i,j,k. -/
def component (w : H) (i : Fin 4) : ℝ := Quaternion.linearIsometryEquivTuple w i

def parameterBasis (i : Fin 4) : H :=
  Quaternion.linearIsometryEquivTuple.symm (EuclideanSpace.single i 1)

/-- Real partials are directional derivatives along the four coordinate axes. -/
def componentPartial (E : H → ℝ) (w : H) (i : Fin 4) : ℝ :=
  fderiv ℝ E w (parameterBasis i)

theorem componentPartial_eq_gradient {E : H → ℝ} {w g : H}
    (hg : HasGradientAt E g w) (i : Fin 4) :
    componentPartial E w i = component g i := by
  rw [componentPartial, hg.hasFDerivAt.fderiv]
  change inner ℝ g (parameterBasis i) = _
  rw [← Quaternion.linearIsometryEquivTuple.inner_map_map g (parameterBasis i)]
  simp only [parameterBasis, LinearIsometryEquiv.apply_symm_apply,
    EuclideanSpace.inner_single_right]
  simp [component]

/-- The directional formula is an actual one-variable coordinate partial. -/
theorem componentPartial_hasDerivAt {E : H → ℝ} {w g : H}
    (hg : HasGradientAt E g w) (i : Fin 4) :
    HasDerivAt (fun t : ℝ => E (w + t • parameterBasis i)) (componentPartial E w i) 0 := by
  have hp : HasDerivAt (fun t : ℝ => w + t • parameterBasis i) (parameterBasis i) 0 := by
    simpa using ((hasDerivAt_id (0 : ℝ)).smul_const (parameterBasis i)).const_add w
  have hd := hg.hasFDerivAt.comp_hasDerivAt_of_eq (0 : ℝ) hp (by simp)
  simpa only [componentPartial, hg.hasFDerivAt.fderiv] using! hd

/-- Exact agreement with the displayed four-component update. -/
theorem quaternion_gradientStep_component (η : ℝ) (w g : H) (i : Fin 4) :
    component (gradientStep η w g) i = component w i - η * component g i := by
  fin_cases i <;> simp [component, gradientStep]

theorem quaternion_update_eq_partials {E : H → ℝ} {w g : H}
    (hg : HasGradientAt E g w) (η : ℝ) (i : Fin 4) :
    component (gradientStep η w g) i = component w i - η * componentPartial E w i := by
  rw [quaternion_gradientStep_component, componentPartial_eq_gradient hg]
end QNN
