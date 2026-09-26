import TypeEmbeddings.RGB.Decoding
import TypeEmbeddings.RGB.Rounding
import TypeEmbeddings.Numerics.BFloat16

/-! Checked counterexamples. These diagnostics are not public runtime dependencies. -/

noncomputable section
open scoped Quaternion
namespace TypeEmbeddings

/-- All blocks can agree on a wrong code with zero residual. -/
theorem wrongCode_zeroResidual {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (target wrong : RGB) (hwrong : wrong ≠ target) :
    residual w (encoder w (rgbValue wrong)) = 0 ∧
      decodeRGB w (encoder w (rgbValue wrong)) ≠ target := by
  constructor
  · simp [residual, decoder_roundTrip w hS]
  · simpa [decodeRGB_roundTrip w hS] using hwrong

/-- Summing two quaternion inputs through a shared bank can have a nontrivial kernel,
even when the weight is nonzero. A single-input Gram theorem cannot cover this map. -/
theorem sharedTwoInput_not_injective (w : Quaternion ℝ) :
    ¬Function.Injective (fun p : Quaternion ℝ × Quaternion ℝ => p.1 * w + p.2 * w) := by
  intro hinj
  have hp : ((1, -1) : Quaternion ℝ × Quaternion ℝ) = (0, 0) :=
    hinj (by simp)
  have hf := congrArg (fun p : Quaternion ℝ × Quaternion ℝ => p.1.re) hp
  norm_num at hf

def storageCounterBank : Fin 1 → Quaternion ℝ := fun _ => ⟨1, 2, 3, 4⟩
def storageCounterRGB : RGB := ![0, 0, 16]
def storageRoundedCode : BankSpace 1 := WithLp.toLp 2 (fun _ => ⟨135/16, -19/8, 5/4, -239/128⟩)

theorem storageCounter_energy : bankEnergy storageCounterBank = 30 := by
  norm_num [bankEnergy, storageCounterBank, Quaternion.normSq_def', Fin.sum_univ_one]

theorem storageCounter_encode : encoder storageCounterBank (rgbValue storageCounterRGB) 0 =
    (⟨2167/256, -303/128, 319/256, -239/128⟩ : Quaternion ℝ) := by
  ext <;> norm_num [encoder_apply, storageCounterBank, storageCounterRGB,
    rgbValue, pureRGB, pureRGBLinear, channelValue, Matrix.cons_val_two, Matrix.vecHead, Matrix.vecTail]

/-- All four weights are exactly representable normal BF16 numbers. -/
theorem storageCounter_weights_bf16 (j : Fin 4) :
    IsNormalBF16 (Quaternion.equivTuple ℝ (storageCounterBank 0) j) := by
  fin_cases j
  · exact ⟨128, -7, by norm_num [storageCounterBank, Quaternion.equivTuple_apply]⟩
  · exact ⟨128, -6, by norm_num [storageCounterBank, Quaternion.equivTuple_apply]⟩
  · exact ⟨192, -6, by norm_num [storageCounterBank, Quaternion.equivTuple_apply]⟩
  · exact ⟨128, -5, by norm_num [storageCounterBank, Quaternion.equivTuple_apply]⟩

/-- The chosen rounded code follows ideal normal BF16 ties-to-even storage semantics. -/
theorem storageCounter_rounding (j : Fin 4) :
    RoundsNormalBF16
      (Quaternion.equivTuple ℝ (encoder storageCounterBank (rgbValue storageCounterRGB) 0) j)
      (Quaternion.equivTuple ℝ (storageRoundedCode 0) j) := by
  rw [storageCounter_encode]
  fin_cases j
  · refine ⟨135, -4, ?_⟩
    norm_num [Quaternion.equivTuple_apply, storageRoundedCode]
  · refine ⟨-152, -6, ?_⟩
    norm_num [Quaternion.equivTuple_apply, storageRoundedCode]
    exact ⟨76, by norm_num⟩
  · refine ⟨160, -7, ?_⟩
    norm_num [Quaternion.equivTuple_apply, storageRoundedCode]
    exact ⟨80, by norm_num⟩
  · refine ⟨-239, -7, ?_⟩
    norm_num [Quaternion.equivTuple_apply, storageRoundedCode]

theorem storageCounter_decode_location : analyticDecoder storageCounterBank storageRoundedCode =
    !₂[-3821/3840, -1909/1920, -1109/1280] := by
  rw [decoder_fused, storageCounter_energy]
  ext j
  fin_cases j <;> norm_num [storageCounterBank, storageRoundedCode, Fin.sum_univ_one,
    imaginary, imaginaryLinear]

/-- Representable grid and weights do not guarantee an exact rounded-code round-trip. -/
theorem storageCounter_wrong_decode : decodeRGB storageCounterBank storageRoundedCode = ![0, 0, 17] := by
  unfold decodeRGB
  rw [storageCounter_decode_location]
  funext j
  fin_cases j <;> apply nearestChannel_eq_of_interval
  all_goals intro h
  all_goals norm_num [channelIndex] at *

end TypeEmbeddings
