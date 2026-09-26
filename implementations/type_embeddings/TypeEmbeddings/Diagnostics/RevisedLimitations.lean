import TypeEmbeddings.Diagnostics.Limitations
import TypeEmbeddings.RGB.EvenDecoding
import TypeEmbeddings.Reader.Width

/-! The precision and consistency limitations persist under the revised default decoder. -/

noncomputable section
namespace TypeEmbeddings

theorem wrongCode_floorWidth {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (p : WidthParameters) (target wrong : RGB)
    (hwrong : wrong ≠ target) :
    residualVariance w p (encoder w (rgbValue wrong)) = p.floor ^ 2 ∧
      decodeRGBEven w (encoder w (rgbValue wrong)) ≠ target := by
  constructor
  · exact residualVariance_at_code w hS p _
  · simpa only [decodeRGBEven_roundTrip w hS] using hwrong

theorem storageCounter_wrong_even_decode :
    decodeRGBEven storageCounterBank storageRoundedCode = ![0, 0, 17] := by
  apply decodeRGBEven_exact_of_margin
  intro j
  rw [storageCounter_decode_location]
  fin_cases j <;> norm_num [channelValue]

end TypeEmbeddings
