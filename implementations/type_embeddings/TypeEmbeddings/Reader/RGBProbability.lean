import TypeEmbeddings.Reader.Width
import TypeEmbeddings.Probability.PMF
import TypeEmbeddings.Probability.EvenMode

/-! The revised RGB head uses one residual-derived scale for all three channels. -/

noncomputable section
namespace TypeEmbeddings

def rgbReaderProbability {N : ℕ} (w : Fin N → Quaternion ℝ)
    (p : WidthParameters) (h : BankSpace N) (c : RGB) : ℝ :=
  rgbProbability (analyticDecoder w h) (fun _ => residualScale w p h) c

theorem rgbReaderProbability_sum {N : ℕ} (w : Fin N → Quaternion ℝ)
    (p : WidthParameters) (h : BankSpace N) : ∑ c, rgbReaderProbability w p h c = 1 :=
  rgbProbability_sum _ _

theorem rgbReaderProbability_mode {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (p : WidthParameters) (h : BankSpace N) (c : RGB) :
    rgbReaderProbability w p h c ≤
      rgbReaderProbability w p h (nearestRGBEven (analyticDecoder w h)) :=
  rgbProbability_even_mode _ _ (fun _ => residualScale_pos w hS p h) c

def rgbReaderPMF {N : ℕ} (w : Fin N → Quaternion ℝ) (hS : 0 < bankEnergy w)
    (p : WidthParameters) (h : BankSpace N) : PMF RGB :=
  rgbPMF (analyticDecoder w h) (fun _ => ⟨residualScale w p h, residualScale_pos w hS p h⟩)

theorem rgbReaderPMF_apply {N : ℕ} (w : Fin N → Quaternion ℝ) (hS : 0 < bankEnergy w)
    (p : WidthParameters) (h : BankSpace N) (c : RGB) :
    rgbReaderPMF w hS p h c = ENNReal.ofReal (rgbReaderProbability w p h c) := rfl

end TypeEmbeddings
