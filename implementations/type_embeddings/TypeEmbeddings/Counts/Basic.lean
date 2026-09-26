import TypeEmbeddings.RGB.Core
import Mathlib.Data.Fintype.Prod
import Mathlib.Data.Fintype.Sum

/-! Counts of coefficient slots, excluding type/text embeddings, offsets, and adapters.
These are stored trainable coefficients, not degrees of freedom after normalization. -/

namespace TypeEmbeddings

abbrev QuaternionCoefficients (N : ℕ) := Fin N × Fin 4
abbrev DenseRGBCoefficients (d : ℕ) := Fin d × Fin 3
abbrev UntiedRGBCoefficients (d : ℕ) := (Fin d × Fin 3) ⊕ (Fin 3 × Fin d)
abbrev UntiedQuaternionCoefficients (N : ℕ) := QuaternionCoefficients N ⊕ QuaternionCoefficients N
abbrev UntiedPaddedCoefficients (d : ℕ) := (Fin d × Fin 4) ⊕ (Fin 4 × Fin d)
abbrev ScalePredictorCoefficients (d : ℕ) := (Fin 3 × Fin d) ⊕ Fin 3

theorem coreCoefficient_count (N : ℕ) : Fintype.card (QuaternionCoefficients N) = 4 * N := by
  simp [QuaternionCoefficients, Nat.mul_comm]

theorem tiedReal_count (d : ℕ) : Fintype.card (DenseRGBCoefficients d) = 3 * d := by
  simp [DenseRGBCoefficients, Nat.mul_comm]

theorem untiedRGB_count (d : ℕ) : Fintype.card (UntiedRGBCoefficients d) = 6 * d := by
  simp [UntiedRGBCoefficients]
  omega

theorem untiedQuaternion_count (N : ℕ) : Fintype.card (UntiedQuaternionCoefficients N) = 2 * (4 * N) := by
  simp [UntiedQuaternionCoefficients, QuaternionCoefficients, Nat.mul_comm, two_mul]

theorem untiedPadded_count (d : ℕ) : Fintype.card (UntiedPaddedCoefficients d) = 8 * d := by
  simp [UntiedPaddedCoefficients]
  omega

theorem scalePredictor_count (d : ℕ) : Fintype.card (ScalePredictorCoefficients d) = 3 * d + 3 := by
  simp [ScalePredictorCoefficients]

/-- Atomic RGB enumeration comparison, not a requirement on ordinary tokenizers. -/
theorem atomicRGB_512_count : Fintype.card (RGB × Fin 512) = 8589934592 := by
  rw [Fintype.card_prod, rgb_card]
  norm_num

/-- Exactly 16 GiB at two bytes per coefficient; no optimizer or other model storage. -/
theorem atomicRGB_512_bf16_bytes : 2 * Fintype.card (RGB × Fin 512) = 16 * 2 ^ 30 := by
  rw [atomicRGB_512_count]
  norm_num

theorem bank_512_count : Fintype.card (QuaternionCoefficients 128) = 512 := by
  rw [coreCoefficient_count]

/-- Three channel normalizers each enumerate 256 scores. -/
theorem channelScore_count : Fintype.card (Fin 3 × Channel) = 768 := by simp [Channel]

end TypeEmbeddings
