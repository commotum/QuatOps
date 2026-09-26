import Qrnn.Forward

/-!
# Exact counts of independent real architecture parameters

These are counts of finite scalar-coordinate indices, not cardinalities of the
uncountable parameter types. Biases are included explicitly. Matching a quaternion
width to a real width multiplies each neuron dimension by four.
-/

namespace Qrnn
noncomputable section

abbrev QuaternionMatrixCoordinateIndex (m n : ℕ) := (Fin m × Fin n) × Fin 4

/-- A quaternion matrix is in bijection with its independent four-component coordinates. -/
def matrixCoordinateEquiv (m n : ℕ) : QMatrix m n ≃ (QuaternionMatrixCoordinateIndex m n → ℝ) where
  toFun W := fun k => components (W k.1.1 k.1.2) k.2
  invFun c := fun i j => ofComponents (fun a => c ((i,j),a))
  left_inv W := by
    funext i j
    exact ofComponents_components (W i j)
  right_inv c := by
    funext ⟨⟨i,j⟩,a⟩
    exact congrFun (components_ofComponents _) a

/-- Exact independent scalar count, including zero-sized matrix shapes. -/
theorem weight_parameter_count (m n : ℕ) :
    Fintype.card (QuaternionMatrixCoordinateIndex m n) = 4*m*n := by
  simp [QuaternionMatrixCoordinateIndex]
  ring

/-- The arbitrary real block-sized matrix has four times as many free coordinates. -/
theorem weight_parameter_fourfold (m n : ℕ) :
    Fintype.card (Fin (4*m) × Fin (4*n)) = 4 * Fintype.card (QuaternionMatrixCoordinateIndex m n) := by
  simp [weight_parameter_count]
  ring

abbrev QRNNWeightIndex (d h o : ℕ) :=
  (Fin h × Fin h) ⊕ ((Fin h × Fin d) ⊕ (Fin o × Fin h))
abbrev QRNNParameterIndex (d h o : ℕ) := QRNNWeightIndex d h o ⊕ Fin h
abbrev QRNNRealParameterIndex (d h o : ℕ) := QRNNParameterIndex d h o × Fin 4

/-- Select exactly one stored quaternion parameter. -/
def qrnnParameterAt {d h o : ℕ} (p : QRNNParams d h o) : QRNNParameterIndex d h o → Q
  | .inl (.inl (i,j)) => p.recurrent i j
  | .inl (.inr (.inl (i,j))) => p.input i j
  | .inl (.inr (.inr (i,j))) => p.output i j
  | .inr i => p.bias i

/-- Every independent real component occurs once in this coordinate representation. -/
def qrnnCoordinates {d h o : ℕ} (p : QRNNParams d h o) : QRNNRealParameterIndex d h o → ℝ :=
  fun k => components (qrnnParameterAt p k.1) k.2

def qrnnFromCoordinates {d h o : ℕ} (c : QRNNRealParameterIndex d h o → ℝ) : QRNNParams d h o :=
  ⟨fun i j => ofComponents (fun a => c (.inl (.inl (i,j)), a)),
   fun i j => ofComponents (fun a => c (.inl (.inr (.inl (i,j))), a)),
   fun i j => ofComponents (fun a => c (.inl (.inr (.inr (i,j))), a)),
   fun i => ofComponents (fun a => c (.inr i, a))⟩

/-- The count is justified by a bijection with unrestricted real coordinates. -/
def qrnnCoordinateEquiv (d h o : ℕ) : QRNNParams d h o ≃ (QRNNRealParameterIndex d h o → ℝ) where
  toFun := qrnnCoordinates
  invFun := qrnnFromCoordinates
  left_inv p := by
    cases p
    simp only [qrnnFromCoordinates, qrnnCoordinates, qrnnParameterAt, ofComponents_components]
  right_inv c := by
    funext ⟨k, a⟩
    rcases k with ((⟨i,j⟩ | ⟨i,j⟩ | ⟨i,j⟩) | i) <;>
      simp only [qrnnCoordinates, qrnnParameterAt, qrnnFromCoordinates, components_ofComponents]

/-- Independent real scalar count for the printed QRNN, with no output bias. -/
def qrnnParameterCount (d h o : ℕ) : ℕ := 4 * (h*h + h*d + o*h + h)

theorem qrnn_parameter_count (d h o : ℕ) :
    Fintype.card (QRNNRealParameterIndex d h o) = qrnnParameterCount d h o := by
  simp [QRNNRealParameterIndex, QRNNParameterIndex, QRNNWeightIndex, qrnnParameterCount]
  ring

/-- Dense real QRNN count with the same bias/output-head convention. -/
def realRNNParameterCount (d h o : ℕ) : ℕ := h*h + h*d + o*h + h

/-- Weight-only counts have an exact fourfold saving at matched real widths. -/
theorem qrnn_weight_fourfold (d h o : ℕ) :
    (4*h)*(4*h) + (4*h)*(4*d) + (4*o)*(4*h) = 4 * (4*(h*h+h*d+o*h)) := by ring

/-- Bias coordinates are not reduced fourfold, so the whole-model factor has this correction. -/
theorem qrnn_parameter_bias_correction (d h o : ℕ) :
    realRNNParameterCount (4*d) (4*h) (4*o) + 12*h = 4 * qrnnParameterCount d h o := by
  simp only [realRNNParameterCount, qrnnParameterCount]
  ring

abbrev GateParameterIndex (d h : ℕ) := (Fin h × Fin d) ⊕ ((Fin h × Fin h) ⊕ Fin h)
abbrev GateRealParameterIndex (d h : ℕ) := GateParameterIndex d h × Fin 4
abbrev QLSTMRealParameterIndex (d h : ℕ) := Fin 4 × GateRealParameterIndex d h
abbrev QLSTMWeightIndex (d h : ℕ) := Fin 4 × ((Fin h × Fin d) ⊕ (Fin h × Fin h))

def gateParameterAt {d h : ℕ} (p : GateParams d h) : GateParameterIndex d h → Q
  | .inl (i,j) => p.input i j
  | .inr (.inl (i,j)) => p.recurrent i j
  | .inr (.inr i) => p.bias i

def gateCoordinates {d h : ℕ} (p : GateParams d h) : GateRealParameterIndex d h → ℝ :=
  fun k => components (gateParameterAt p k.1) k.2

def gateFromCoordinates {d h : ℕ} (c : GateRealParameterIndex d h → ℝ) : GateParams d h :=
  ⟨fun i j => ofComponents (fun a => c (.inl (i,j), a)),
   fun i j => ofComponents (fun a => c (.inr (.inl (i,j)), a)),
   fun i => ofComponents (fun a => c (.inr (.inr i), a))⟩

def gateCoordinateEquiv (d h : ℕ) : GateParams d h ≃ (GateRealParameterIndex d h → ℝ) where
  toFun := gateCoordinates
  invFun := gateFromCoordinates
  left_inv p := by
    cases p
    simp only [gateFromCoordinates, gateCoordinates, gateParameterAt, ofComponents_components]
  right_inv c := by
    funext ⟨k,a⟩
    rcases k with (⟨i,j⟩ | ⟨i,j⟩ | i) <;>
      simp only [gateCoordinates, gateParameterAt, gateFromCoordinates, components_ofComponents]

/-- The four gate maps have separate, independently free coordinates. -/
def qlstmCoordinateEquiv (d h : ℕ) : QLSTMParams d h ≃ (QLSTMRealParameterIndex d h → ℝ) where
  toFun p := fun k => gateCoordinates (![p.forget, p.input, p.candidate, p.output] k.1) k.2
  invFun c := ⟨gateFromCoordinates (fun k => c (0,k)), gateFromCoordinates (fun k => c (1,k)),
    gateFromCoordinates (fun k => c (2,k)), gateFromCoordinates (fun k => c (3,k))⟩
  left_inv p := by
    change QLSTMParams.mk ((gateCoordinateEquiv d h).symm ((gateCoordinateEquiv d h) p.forget))
      ((gateCoordinateEquiv d h).symm ((gateCoordinateEquiv d h) p.input))
      ((gateCoordinateEquiv d h).symm ((gateCoordinateEquiv d h) p.candidate))
      ((gateCoordinateEquiv d h).symm ((gateCoordinateEquiv d h) p.output)) = p
    simp
  right_inv c := by
    funext ⟨g,k⟩
    fin_cases g
    · exact congrFun ((gateCoordinateEquiv d h).apply_symm_apply (fun k => c (0,k))) k
    · exact congrFun ((gateCoordinateEquiv d h).apply_symm_apply (fun k => c (1,k))) k
    · exact congrFun ((gateCoordinateEquiv d h).apply_symm_apply (fun k => c (2,k))) k
    · exact congrFun ((gateCoordinateEquiv d h).apply_symm_apply (fun k => c (3,k))) k

/-- Four affine gates/candidate, each with input/recurrent weights and a bias; no head. -/
def qlstmParameterCount (d h : ℕ) : ℕ := 16 * (h*d + h*h + h)

theorem qlstm_parameter_count (d h : ℕ) :
    Fintype.card (QLSTMRealParameterIndex d h) = qlstmParameterCount d h := by
  simp [QLSTMRealParameterIndex, GateRealParameterIndex, GateParameterIndex, qlstmParameterCount]
  ring

def realLSTMParameterCount (d h : ℕ) : ℕ := 4 * (h*d + h*h + h)

theorem qlstm_weight_fourfold (d h : ℕ) :
    4*((4*h)*(4*d)+(4*h)*(4*h)) = 4*(16*(h*d+h*h)) := by ring

/-- Four gates each contribute the bias discrepancy; whole-model saving is not exactly fourfold. -/
theorem qlstm_parameter_bias_correction (d h : ℕ) :
    realLSTMParameterCount (4*d) (4*h) + 48*h = 4 * qlstmParameterCount d h := by
  simp only [realLSTMParameterCount, qlstmParameterCount]
  ring

end
end Qrnn
