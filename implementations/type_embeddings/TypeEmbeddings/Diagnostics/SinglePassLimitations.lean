import TypeEmbeddings.Text.Decoder
import TypeEmbeddings.Text.Scoring
import Mathlib.Data.Fin.VecNotation

/-! A concrete ranking flip when the inverse is substituted for the adjoint.
These intentionally unnormalized groups illustrate why the distinction matters. -/

noncomputable section
open scoped Quaternion RealInnerProductSpace
namespace TypeEmbeddings.Text

def unequalEnergyBank : ∀ _ : Fin 2, Fin 1 → Quaternion ℝ :=
  fun j _ => if j = 0 then 1 else ⟨2, 0, 0, 0⟩

def unequalEnergyHidden : OutputSpace (fun _ : Fin 2 => 1) := WithLp.toLp 2 (fun _ => 1)

def axisDictionary (v : Fin 2) : MRSpace (Fin 2) :=
  WithLp.toLp 2 (fun j => if j = v then 1 else 0)

theorem unequalEnergy_adjoint_scores :
    compactScore unequalEnergyBank axisDictionary unequalEnergyHidden 0 = 1 ∧
    compactScore unequalEnergyBank axisDictionary unequalEnergyHidden 1 = 2 := by
  constructor <;>
    simp [compactScore, axisDictionary, PiLp.inner_apply, Fin.sum_univ_two,
      groupedAdjoint_apply, unequalEnergyBank, unequalEnergyHidden,
      Quaternion.inner_def]

theorem unequalEnergy_inverse_scores :
    ⟪axisDictionary 0, groupedInverse unequalEnergyBank unequalEnergyHidden⟫ = 1 ∧
    ⟪axisDictionary 1, groupedInverse unequalEnergyBank unequalEnergyHidden⟫ = 1 / 2 := by
  constructor <;>
    norm_num [axisDictionary, PiLp.inner_apply, Fin.sum_univ_two,
      groupedInverse_apply, groupedAdjoint_apply, unequalEnergyBank, unequalEnergyHidden,
      groupEnergy, Fin.sum_univ_one, Quaternion.normSq_def', Quaternion.inner_def]

theorem inverse_can_reverse_ranking :
    compactScore unequalEnergyBank axisDictionary unequalEnergyHidden 0 <
      compactScore unequalEnergyBank axisDictionary unequalEnergyHidden 1 ∧
    ⟪axisDictionary 1, groupedInverse unequalEnergyBank unequalEnergyHidden⟫ <
      ⟪axisDictionary 0, groupedInverse unequalEnergyBank unequalEnergyHidden⟫ := by
  rw [unequalEnergy_adjoint_scores.1, unequalEnergy_adjoint_scores.2,
    unequalEnergy_inverse_scores.1, unequalEnergy_inverse_scores.2]
  norm_num

end TypeEmbeddings.Text
