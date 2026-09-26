import Mathlib.Data.Real.Basic
import Mathlib.Data.Fintype.Card
import Mathlib.Data.Fintype.BigOperators
import Mathlib.Data.Fintype.Pi
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

/-! Exact algebraic RGB coordinates. No floating-point semantics are assumed. -/

noncomputable section
namespace TypeEmbeddings

abbrev Channel := Fin 256
abbrev RGB := Fin 3 → Channel

/-- Coerce to reals before arithmetic, avoiding byte overflow. -/
def channelValue (c : Channel) : ℝ := (2 * (c.val : ℝ) - 255) / 256

theorem channelValue_difference (a b : Channel) :
    channelValue b - channelValue a = ((b.val : ℝ) - (a.val : ℝ)) / 128 := by
  unfold channelValue
  ring

theorem channelValue_injective : Function.Injective channelValue := by
  intro a b heq
  have h : (a.val : ℝ) = (b.val : ℝ) := by
    unfold channelValue at heq
    linarith
  apply Fin.ext
  exact_mod_cast h

theorem channelValue_zero : channelValue 0 = -255 / 256 := by norm_num [channelValue]
theorem channelValue_last : channelValue 255 = 255 / 256 := by norm_num [channelValue]

theorem channelValue_bounds (c : Channel) :
    -255 / 256 ≤ channelValue c ∧ channelValue c ≤ 255 / 256 := by
  have h0 : 0 ≤ (c.val : ℝ) := Nat.cast_nonneg _
  have h255 : (c.val : ℝ) ≤ 255 := by exact_mod_cast (Nat.le_of_lt_succ c.isLt)
  unfold channelValue
  constructor <;> linarith

theorem rgb_card : Fintype.card RGB = 16777216 := by
  norm_num [RGB, Channel, Fintype.card_fun]

end TypeEmbeddings
