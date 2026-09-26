import Qrnn.ParameterCounts

/-!
# Explicit dense scalar-operation schedules

A direct Hamilton product uses 16 scalar multiplications and 12 additions or
subtractions. Dot products here accumulate from zero and charge four additional
scalar additions per quaternion term. Each QRNN step includes its output head;
QLSTM counts four affine gates, its cell update and hidden output, without a head.
Assignments, conjugate/sign metadata and memory traffic are not arithmetic ops.
Scalar activation evaluation costs are supplied as fixed natural numbers.
These are architecture schedule counts, not measured Lean execution times.
-/

namespace Qrnn

abbrev HamiltonMulIndex := Fin 4 × Fin 4
abbrev HamiltonAddIndex := Fin 4 × Fin 3

theorem hamilton_naive_cost :
    Fintype.card HamiltonMulIndex = 16 ∧ Fintype.card HamiltonAddIndex = 12 ∧
      Fintype.card HamiltonMulIndex + Fintype.card HamiltonAddIndex = 28 := by decide

abbrev QRNNMulIndex (d h o : ℕ) := QRNNWeightIndex d h o × HamiltonMulIndex
/-- Hamilton internal operations, dot accumulation, then two hidden-vector additions. -/
abbrev QRNNAddIndex (d h o : ℕ) :=
  (QRNNWeightIndex d h o × (HamiltonAddIndex ⊕ Fin 4)) ⊕ (Fin h × Fin 2 × Fin 4)

def qrnnMulCount (d h o : ℕ) : ℕ := Fintype.card (QRNNMulIndex d h o)
def qrnnAddCount (d h o : ℕ) : ℕ := Fintype.card (QRNNAddIndex d h o)

theorem qrnn_multiplication_count (d h o : ℕ) :
    qrnnMulCount d h o = 16 * (h*h+h*d+o*h) := by
  simp [qrnnMulCount, QRNNMulIndex, QRNNWeightIndex, HamiltonMulIndex]
  ring

theorem qrnn_addition_count (d h o : ℕ) :
    qrnnAddCount d h o = 16 * (h*h+h*d+o*h) + 8*h := by
  simp [qrnnAddCount, QRNNAddIndex, QRNNWeightIndex, HamiltonAddIndex]
  ring

/-- Cost per QRNN state update and readout under the documented schedule. -/
def qrnnScalarCost (d h o hiddenActivationCost outputActivationCost : ℕ) : ℕ :=
  qrnnMulCount d h o + qrnnAddCount d h o +
    Fintype.card (Fin h × Fin 4) * hiddenActivationCost +
    Fintype.card (Fin o × Fin 4) * outputActivationCost

theorem qrnn_step_cost (d h o α β : ℕ) :
    qrnnScalarCost d h o α β = 32*(h*h+h*d+o*h) + 8*h + 4*h*α + 4*o*β := by
  rw [qrnnScalarCost, qrnn_multiplication_count, qrnn_addition_count]
  simp only [Fintype.card_prod, Fintype.card_fin]
  ring

/-- Twelve scalar gate products per quaternion hidden unit (three Hadamard products). -/
abbrev QLSTMMulIndex (d h : ℕ) :=
  (QLSTMWeightIndex d h × HamiltonMulIndex) ⊕ (Fin 3 × Fin h × Fin 4)
/-- Internal Hamilton/dot operations, two affine additions per gate, one cell merge. -/
abbrev QLSTMAddIndex (d h : ℕ) :=
  (QLSTMWeightIndex d h × (HamiltonAddIndex ⊕ Fin 4)) ⊕
    ((Fin 4 × Fin h × Fin 2 × Fin 4) ⊕ (Fin h × Fin 4))

def qlstmMulCount (d h : ℕ) : ℕ := Fintype.card (QLSTMMulIndex d h)
def qlstmAddCount (d h : ℕ) : ℕ := Fintype.card (QLSTMAddIndex d h)

theorem qlstm_multiplication_count (d h : ℕ) :
    qlstmMulCount d h = 64*(h*d+h*h) + 12*h := by
  simp [qlstmMulCount, QLSTMMulIndex, QLSTMWeightIndex, HamiltonMulIndex]
  ring

theorem qlstm_addition_count (d h : ℕ) :
    qlstmAddCount d h = 64*(h*d+h*h) + 36*h := by
  simp [qlstmAddCount, QLSTMAddIndex, QLSTMWeightIndex, HamiltonAddIndex]
  ring

/-- Three split gate activations and two split candidate/cell activations. -/
def qlstmScalarCost (d h gateActivationCost tanhActivationCost : ℕ) : ℕ :=
  qlstmMulCount d h + qlstmAddCount d h +
    Fintype.card (Fin 3 × Fin h × Fin 4) * gateActivationCost +
    Fintype.card (Fin 2 × Fin h × Fin 4) * tanhActivationCost

theorem qlstm_step_cost (d h α τ : ℕ) :
    qlstmScalarCost d h α τ = 128*(h*d+h*h) + 48*h + 12*h*α + 8*h*τ := by
  rw [qlstmScalarCost, qlstm_multiplication_count, qlstm_addition_count]
  simp only [Fintype.card_prod, Fintype.card_fin]
  ring

/-- With all widths scaled together and fixed scalar activation costs, the cost is quadratic. -/
theorem qrnn_cost_equal_width (n α β : ℕ) :
    qrnnScalarCost n n n α β = 96*n^2 + (8+4*α+4*β)*n := by rw [qrnn_step_cost]; ring

theorem qlstm_cost_equal_width (n α τ : ℕ) :
    qlstmScalarCost n n α τ = 256*n^2 + (48+12*α+8*τ)*n := by rw [qlstm_step_cost]; ring

/-- Explicit upper and lower bounds, rather than an unstated asymptotic scaling convention. -/
theorem qrnn_cost_quadratic_bounds (n α β : ℕ) :
    96*n^2 ≤ qrnnScalarCost n n n α β ∧
      qrnnScalarCost n n n α β ≤ (104+4*α+4*β)*n^2 := by
  rw [qrnn_cost_equal_width]
  have hn : n ≤ n^2 := by cases n <;> nlinarith
  constructor
  · omega
  · calc
      _ ≤ 96*n^2 + (8+4*α+4*β)*n^2 :=
        Nat.add_le_add_left (Nat.mul_le_mul_left _ hn) _
      _ = _ := by ring

theorem qlstm_cost_quadratic_bounds (n α τ : ℕ) :
    256*n^2 ≤ qlstmScalarCost n n α τ ∧
      qlstmScalarCost n n α τ ≤ (304+12*α+8*τ)*n^2 := by
  rw [qlstm_cost_equal_width]
  have hn : n ≤ n^2 := by cases n <;> nlinarith
  constructor
  · omega
  · calc
      _ ≤ 256*n^2 + (48+12*α+8*τ)*n^2 :=
        Nat.add_le_add_left (Nat.mul_le_mul_left _ hn) _
      _ = _ := by ring

/-- Sequence schedule repeats the forward step exactly T times; no BPTT runtime is asserted. -/
def qrnnRunScalarCost (T d h o α β : ℕ) : ℕ := T * qrnnScalarCost d h o α β
def qlstmRunScalarCost (T d h α τ : ℕ) : ℕ := T * qlstmScalarCost d h α τ

theorem qrnn_sequence_cost (T d h o α β : ℕ) :
    qrnnRunScalarCost T d h o α β = T*(32*(h*h+h*d+o*h)+8*h+4*h*α+4*o*β) := by
  rw [qrnnRunScalarCost, qrnn_step_cost]

theorem qlstm_sequence_cost (T d h α τ : ℕ) :
    qlstmRunScalarCost T d h α τ = T*(128*(h*d+h*h)+48*h+12*h*α+8*h*τ) := by
  rw [qlstmRunScalarCost, qlstm_step_cost]

end Qrnn
