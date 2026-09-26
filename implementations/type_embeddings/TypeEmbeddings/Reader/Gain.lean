import TypeEmbeddings.Reader.Width
import Mathlib.Analysis.SpecialFunctions.Log.Basic

/-! Positive softplus gain and exact gain-one initialization. -/

noncomputable section
namespace TypeEmbeddings

def softplusGain (rho : ℝ) : ℝ := Real.log (1 + Real.exp rho)

theorem softplusGain_pos (rho : ℝ) : 0 < softplusGain rho :=
  Real.log_pos (lt_add_of_pos_right 1 (Real.exp_pos rho))

theorem softplusGain_one : softplusGain (Real.log (Real.exp 1 - 1)) = 1 := by
  have hp : 0 < Real.exp 1 - 1 := sub_pos.mpr (Real.one_lt_exp_iff.mpr (by norm_num))
  unfold softplusGain
  rw [Real.exp_log hp]
  have he : 1 + (Real.exp 1 - 1) = Real.exp 1 := by ring
  rw [he, Real.log_exp]

def widthParametersSoftplus (floor : ℝ) (hf : 0 < floor) (rho : ℝ) : WidthParameters :=
  ⟨floor, hf, softplusGain rho, softplusGain_pos rho⟩

end TypeEmbeddings
