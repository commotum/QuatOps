import TypeEmbeddings.Reader.Width
import TypeEmbeddings.TypeCode.PMF

/-! The same fused reader and residual width give the shared finite TYPE head. -/

noncomputable section
namespace TypeEmbeddings

variable {α : Type*} [Fintype α] [Nonempty α]

def typeReaderProbability {N : ℕ} (w : Fin N → Quaternion ℝ)
    (a : TypeCodebook α) (p : WidthParameters) (h : BankSpace N) (t : α) : ℝ :=
  typeProbability a.code (analyticDecoder w h) (residualVariance w p h) t

theorem typeReaderProbability_sum {N : ℕ} (w : Fin N → Quaternion ℝ)
    (a : TypeCodebook α) (p : WidthParameters) (h : BankSpace N) :
    ∑ t, typeReaderProbability w a p h t = 1 := typeProbability_sum _ _ _

theorem typeReaderProbability_mode {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (a : TypeCodebook α) (p : WidthParameters)
    (h : BankSpace N) (t : α) : typeReaderProbability w a p h t ≤
      typeReaderProbability w a p h (nearestType a.code (analyticDecoder w h)) :=
  typeProbability_mode _ _ _ (residualVariance_pos w hS p h) t

def typeReaderPMF {N : ℕ} (w : Fin N → Quaternion ℝ) (hS : 0 < bankEnergy w)
    (a : TypeCodebook α) (p : WidthParameters) (h : BankSpace N) : PMF α :=
  typePMF a.code (analyticDecoder w h) ⟨residualVariance w p h, residualVariance_pos w hS p h⟩

theorem typeReaderPMF_apply {N : ℕ} (w : Fin N → Quaternion ℝ) (hS : 0 < bankEnergy w)
    (a : TypeCodebook α) (p : WidthParameters) (h : BankSpace N) (t : α) :
    typeReaderPMF w hS a p h t = ENNReal.ofReal (typeReaderProbability w a p h t) := rfl

end TypeEmbeddings
