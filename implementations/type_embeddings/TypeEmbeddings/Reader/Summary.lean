import TypeEmbeddings.Reader.RGBProbability
import TypeEmbeddings.Reader.TypeProbability

/-! Public reader outputs. Consistency and kernel scale carry no calibration assertion. -/

noncomputable section
namespace TypeEmbeddings

structure ReaderSummary (α : Type*) where
  location : RGBSpace
  kernelScale : PositiveScale
  consistencyResidual : {r : ℝ // 0 ≤ r}
  probabilities : PMF α

def rgbReaderSummary {N : ℕ} (w : Fin N → Quaternion ℝ) (hS : 0 < bankEnergy w)
    (p : WidthParameters) (h : BankSpace N) : ReaderSummary RGB :=
  ⟨analyticDecoder w h, ⟨residualScale w p h, residualScale_pos w hS p h⟩,
    ⟨residualEnergy w h, residualEnergy_nonneg w h⟩, rgbReaderPMF w hS p h⟩

def typeReaderSummary {α : Type*} [Fintype α] [Nonempty α] {N : ℕ}
    (w : Fin N → Quaternion ℝ) (hS : 0 < bankEnergy w)
    (a : TypeCodebook α) (p : WidthParameters) (h : BankSpace N) : ReaderSummary α :=
  ⟨analyticDecoder w h, ⟨residualScale w p h, residualScale_pos w hS p h⟩,
    ⟨residualEnergy w h, residualEnergy_nonneg w h⟩, typeReaderPMF w hS a p h⟩

end TypeEmbeddings
