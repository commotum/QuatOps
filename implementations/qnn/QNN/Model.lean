import QNN.Geometry
import Mathlib.Analysis.SpecialFunctions.Sigmoid

/-!
# Forward model and error

The printed denominator is interpreted as the norm, not its square. The Lean
function is total with value zero for a zero weight. Agreement with the printed
quotient and all subsequent smoothness claims are on nonzero weights. This zero
extension is an explicit model convention, not a claim of smoothness at zero.
-/
noncomputable section
namespace QNN

/-- Eq. (11)'s weighted input, including the explicitly chosen zero extension. -/
def weightAction (w : H) : Pure →ₗ[ℝ] Pure := ‖w‖⁻¹ • conjugatePure w

@[simp] theorem weightAction_zero (x : Pure) : weightAction 0 x = 0 := by
  apply pure_ext
  simp [weightAction]

theorem weightAction_formula (w : H) (x : Pure) :
    (weightAction w x : H) = ‖w‖⁻¹ • (w * (x : H) * star w) := rfl

/-- The denominator preserves weight magnitude: this is a scaled rotation. -/
theorem weightAction_norm (w : H) (hw : w ≠ 0) (x : Pure) :
    ‖weightAction w x‖ = ‖w‖ * ‖x‖ := by
  have hn : ‖w‖ ≠ 0 := norm_ne_zero_iff.mpr hw
  change ‖‖w‖⁻¹ • conjugate w (x : H)‖ = ‖w‖ * ‖(x : H)‖
  rw [norm_smul, Real.norm_eq_abs, abs_inv, abs_of_nonneg (norm_nonneg w),
    conjugate_norm]
  field_simp

/-- Eq. (13): activation is componentwise in the fixed i,j,k coordinate frame. -/
def activation (s : Pure) : Pure :=
  ofVector (fun i => Real.sigmoid (vector s i))

@[simp] theorem activation_coordinate (s : Pure) (i : Fin 3) :
    vector (activation s) i = Real.sigmoid (vector s i) := by
  rw [activation, vector_ofVector]

theorem activation_range (s : Pure) (i : Fin 3) :
    0 < vector (activation s) i ∧ vector (activation s) i < 1 := by
  rw [activation_coordinate]
  exact ⟨Real.sigmoid_pos _, Real.sigmoid_lt_one _⟩

/-- Finite neuron preactivation with the source's subtractive threshold sign. -/
def preactivation {ι : Type*} [Fintype ι] (w : ι → H) (θ : Pure) (x : ι → Pure) : Pure :=
  ∑ i, weightAction (w i) (x i) - θ

/-- Eq. (12). -/
def neuron {ι : Type*} [Fintype ι] (w : ι → H) (θ : Pure) (x : ι → Pure) : Pure :=
  activation (preactivation w θ x)

/-- Preactivation before the threshold is real linear in the entire input layer. -/
def inputLinear {ι : Type*} [Fintype ι] (w : ι → H) : (ι → Pure) →ₗ[ℝ] Pure where
  toFun x := ∑ i, weightAction (w i) (x i)
  map_add' x y := by simp [Finset.sum_add_distrib]
  map_smul' r x := by simp [Finset.smul_sum]

theorem preactivation_eq_inputLinear {ι : Type*} [Fintype ι]
    (w : ι → H) (θ : Pure) (x : ι → Pure) :
    preactivation w θ x = inputLinear w x - θ := rfl

structure Layer (ι ο : Type*) where
  weights : ο → ι → H
  thresholds : ο → Pure

namespace Layer

def forward {ι ο : Type*} [Fintype ι] (L : Layer ι ο) (x : ι → Pure) : ο → Pure :=
  fun j => neuron (L.weights j) (L.thresholds j) x

/-- The open-domain condition needed for weight derivatives. -/
def Admissible {ι ο : Type*} (L : Layer ι ο) : Prop := ∀ j i, L.weights j i ≠ 0
end Layer

/-- Reusable finite feed-forward architecture; each hidden width is explicit. -/
inductive Network : ℕ → ℕ → Type
  | single {m n : ℕ} : Layer (Fin m) (Fin n) → Network m n
  | append {m k n : ℕ} : Network m k → Layer (Fin k) (Fin n) → Network m n

namespace Network

def forward {m n : ℕ} : Network m n → (Fin m → Pure) → (Fin n → Pure)
  | .single L, x => L.forward x
  | .append N L, x => L.forward (N.forward x)

def Admissible {m n : ℕ} : Network m n → Prop
  | .single L => L.Admissible
  | .append N L => N.Admissible ∧ L.Admissible
end Network

/-- The displayed error: one pure output and its pure target. -/
def loss (y d : Pure) : ℝ := (1 / 2 : ℝ) * ‖y - d‖ ^ 2

theorem loss_components (y d : Pure) :
    loss y d = (1 / 2 : ℝ) *
      (((y : H).imI - (d : H).imI) ^ 2 +
        ((y : H).imJ - (d : H).imJ) ^ 2 +
        ((y : H).imK - (d : H).imK) ^ 2) := by
  unfold loss
  change (1 / 2 : ℝ) * ‖(y : H) - (d : H)‖ ^ 2 = _
  rw [norm_sq_components]
  simp

theorem loss_nonneg (y d : Pure) : 0 ≤ loss y d := by unfold loss; positivity

@[simp] theorem loss_eq_zero (y d : Pure) : loss y d = 0 ↔ y = d := by
  simp [loss, sub_eq_zero]

/-- Explicit extension: sum (not mean) of errors over finitely many outputs. -/
def outputLoss {ο : Type*} [Fintype ο] (y d : ο → Pure) : ℝ := ∑ j, loss (y j) (d j)

theorem outputLoss_nonneg {ο : Type*} [Fintype ο] (y d : ο → Pure) :
    0 ≤ outputLoss y d := Finset.sum_nonneg (fun j _ => loss_nonneg (y j) (d j))
end QNN
