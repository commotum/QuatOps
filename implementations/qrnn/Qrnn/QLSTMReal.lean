import Qrnn.Forward

/-!
# QLSTM forward recurrence in real components

This verifies the interpreted architecture with Hamilton affine maps, split
activations and Hadamard gates. It asserts no QLSTM gradient/convergence theorem.
-/

namespace Qrnn
noncomputable section

/-- Real expansion of one gate/candidate affine map. -/
def realGatePreact {d h : ℕ} (p : GateParams d h)
    (x : Fin d × Fin 4 → ℝ) (s : Fin h × Fin 4 → ℝ) : Fin h × Fin 4 → ℝ :=
  (expand p.input).mulVec x + (expand p.recurrent).mulVec s + vectorComponents p.bias

@[simp] theorem gatePreact_expand {d h : ℕ} (p : GateParams d h)
    (x : QVector d) (s : QVector h) :
    vectorComponents (gatePreact p x s) = realGatePreact p (vectorComponents x) (vectorComponents s) := by
  simp [gatePreact, realGatePreact, ← expand_apply]

@[simp] theorem vectorHadamard_components {h : ℕ} (v w : QVector h) :
    vectorComponents (vectorHadamard v w) = vectorComponents v * vectorComponents w := by
  funext ⟨i, a⟩
  exact congrFun (components_hadamard (v i) (w i)) a

/-- QLSTM update on neuron-major real coordinates. Multiplication in the gates
below is componentwise multiplication of real coordinate functions. -/
def realQLSTMStep {d h : ℕ} (p : QLSTMParams d h) (α τ : ℝ → ℝ)
    (x : Fin d × Fin 4 → ℝ)
    (state : (Fin h × Fin 4 → ℝ) × (Fin h × Fin 4 → ℝ)) :
    (Fin h × Fin 4 → ℝ) × (Fin h × Fin 4 → ℝ) :=
  let f := realVectorActivation α (realGatePreact p.forget x state.2)
  let i := realVectorActivation α (realGatePreact p.input x state.2)
  let o := realVectorActivation α (realGatePreact p.output x state.2)
  let candidate := realVectorActivation τ (realGatePreact p.candidate x state.2)
  let cell := f * state.1 + i * candidate
  (cell, o * realVectorActivation τ cell)

/-- Every real component of the quaternion QLSTM step agrees with the real architecture. -/
theorem qlstmStep_expand {d h : ℕ} (p : QLSTMParams d h) (α τ : ℝ → ℝ)
    (x : QVector d) (state : QVector h × QVector h) :
    (vectorComponents (qlstmStep p α τ x state).1,
      vectorComponents (qlstmStep p α τ x state).2) =
      realQLSTMStep p α τ (vectorComponents x) (vectorComponents state.1, vectorComponents state.2) := by
  simp only [qlstmStep, realQLSTMStep, vectorHadamard_components, vectorComponents_add,
    vectorActivation_components, gatePreact_expand]

/-- QLSTM run with explicit fixed initial (cell,hidden) state and input k driving step k+1. -/
def qlstmRun {d h : ℕ} (p : QLSTMParams d h) (α τ : ℝ → ℝ)
    (x : ℕ → QVector d) (initial : QVector h × QVector h) : ℕ → QVector h × QVector h
  | 0 => initial
  | k+1 => qlstmStep p α τ (x k) (qlstmRun p α τ x initial k)

/-- Independently unrolled real QLSTM recurrence. -/
def realQLSTMRun {d h : ℕ} (p : QLSTMParams d h) (α τ : ℝ → ℝ)
    (x : ℕ → Fin d × Fin 4 → ℝ)
    (initial : (Fin h × Fin 4 → ℝ) × (Fin h × Fin 4 → ℝ)) :
    ℕ → (Fin h × Fin 4 → ℝ) × (Fin h × Fin 4 → ℝ)
  | 0 => initial
  | k+1 => realQLSTMStep p α τ (x k) (realQLSTMRun p α τ x initial k)

/-- Finite-horizon QLSTM runs preserve the full real coordinate representation. -/
theorem qlstmRun_expand {d h : ℕ} (p : QLSTMParams d h) (α τ : ℝ → ℝ)
    (x : ℕ → QVector d) (initial : QVector h × QVector h) (T : ℕ) :
    (vectorComponents (qlstmRun p α τ x initial T).1,
      vectorComponents (qlstmRun p α τ x initial T).2) =
      realQLSTMRun p α τ (fun k => vectorComponents (x k))
        (vectorComponents initial.1, vectorComponents initial.2) T := by
  induction T with
  | zero => rfl
  | succ T ih => simp only [qlstmRun, realQLSTMRun, qlstmStep_expand, ih]

end
end Qrnn
