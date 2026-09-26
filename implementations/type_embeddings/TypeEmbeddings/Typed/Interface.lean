import TypeEmbeddings.Bank.Decoder
import TypeEmbeddings.TypeCode.Basic

/-! Concatenation represented structurally by a pair of designated segments.
The product's default norm is not used as a Euclidean concatenation norm.
No claim is made that a transformer preserves either slice. -/

noncomputable section
namespace TypeEmbeddings

abbrev TypedSpace (NT NV : ℕ) := BankSpace NT × BankSpace NV

variable {α : Type*} {β : α → Type*} {NT NV : ℕ}

def typedEmbedding (wT : Fin NT → Quaternion ℝ) (wV : α → Fin NV → Quaternion ℝ)
    (a : TypeCodebook α) (phi : ∀ t, β t → RGBSpace) (z : Sigma β) : TypedSpace NT NV :=
  (encoder wT (a.code z.1), encoder (wV z.1) (phi z.1 z.2))

theorem typedEmbedding_type_roundTrip (wT : Fin NT → Quaternion ℝ)
    (hT : 0 < bankEnergy wT) (wV : α → Fin NV → Quaternion ℝ)
    (a : TypeCodebook α) (phi : ∀ t, β t → RGBSpace) (z : Sigma β) :
    analyticDecoder wT (typedEmbedding wT wV a phi z).1 = a.code z.1 :=
  decoder_roundTrip wT hT _

theorem typedEmbedding_value_roundTrip (wT : Fin NT → Quaternion ℝ)
    (wV : α → Fin NV → Quaternion ℝ) (hV : ∀ t, 0 < bankEnergy (wV t))
    (a : TypeCodebook α) (phi : ∀ t, β t → RGBSpace) (z : Sigma β) :
    analyticDecoder (wV z.1) (typedEmbedding wT wV a phi z).2 = phi z.1 z.2 :=
  decoder_roundTrip (wV z.1) (hV z.1) _

end TypeEmbeddings
